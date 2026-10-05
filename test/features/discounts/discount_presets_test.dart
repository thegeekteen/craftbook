import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart' show AppDatabase;
import 'package:craftbook/database/daos/discount_preset_dao.dart';
import 'package:craftbook/features/discounts/data/repositories/discount_preset_repository_impl.dart';
import 'package:craftbook/features/discounts/domain/entities/discount_preset.dart';
import 'package:craftbook/features/discounts/domain/usecases/discount_preset_usecases.dart';
import 'package:craftbook/features/discounts/presentation/bloc/discount_presets_bloc.dart';
import 'package:craftbook/features/orders/domain/entities/order_discount.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Discount presets against a real in-memory database.
void main() {
  late AppDatabase db;
  late DiscountPresetRepositoryImpl repo;
  late SaveDiscountPreset save;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DiscountPresetRepositoryImpl(DiscountPresetDao(db));
    save = SaveDiscountPreset(repo);
  });
  tearDown(() => db.close());

  Future<List<DiscountPreset>> all() async =>
      (await repo.getPresets() as Success<List<DiscountPreset>>).value;

  group('validateDiscount', () {
    test('needs a name', () {
      expect(validateDiscount(label: ' ', kind: DiscountKind.fixed, value: 5),
          isA<ValidationFailure>());
    });
    test('needs an amount above zero', () {
      expect(validateDiscount(label: 'A', kind: DiscountKind.fixed, value: 0),
          isA<ValidationFailure>());
    });
    test('caps a percentage at 100', () {
      expect(
          validateDiscount(label: 'A', kind: DiscountKind.percent, value: 101),
          isA<ValidationFailure>());
      expect(
          validateDiscount(label: 'A', kind: DiscountKind.percent, value: 100),
          isNull);
    });
    test('a fixed amount may be over 100', () {
      expect(validateDiscount(label: 'A', kind: DiscountKind.fixed, value: 500),
          isNull);
    });
  });

  group('SaveDiscountPreset', () {
    test('adds presets at the end, trimmed', () async {
      expect(
          await save(label: ' Loyal ', kind: DiscountKind.percent, value: 10),
          const Success<void>(null));
      await save(label: 'Bundle', kind: DiscountKind.fixed, value: 50);
      expect((await all()).map((p) => (p.label, p.kind, p.value, p.position)), [
        ('Loyal', DiscountKind.percent, 10.0, 0),
        ('Bundle', DiscountKind.fixed, 50.0, 1),
      ]);
    });

    test('edits by id', () async {
      await save(label: 'Loyal', kind: DiscountKind.percent, value: 10);
      final id = (await all()).single.id;
      await save(
          id: id, label: 'Regulars', kind: DiscountKind.fixed, value: 20);
      final p = (await all()).single;
      expect(
          (p.label, p.kind, p.value), ('Regulars', DiscountKind.fixed, 20.0));
    });

    test('refuses an invalid preset without saving', () async {
      final result =
          await save(label: '', kind: DiscountKind.percent, value: 10);
      expect(result, isA<Error<void>>());
      expect(await all(), isEmpty);
    });

    test('editing a missing preset is reported', () async {
      final result =
          await save(id: 99, label: 'Gone', kind: DiscountKind.fixed, value: 5);
      expect((result as Error<void>).failure, isA<NotFoundFailure>());
    });
  });

  test('reorder sets positions; duplicates are refused', () async {
    await save(label: 'A', kind: DiscountKind.fixed, value: 1);
    await save(label: 'B', kind: DiscountKind.fixed, value: 2);
    final ids = [for (final p in await all()) p.id!];
    final reorder = ReorderDiscountPresets(repo);
    expect(await reorder([ids[0], ids[0]]), isA<Error<void>>());
    await reorder(ids.reversed.toList());
    expect((await all()).map((p) => p.label), ['B', 'A']);
  });

  test('delete removes the preset', () async {
    await save(label: 'A', kind: DiscountKind.fixed, value: 1);
    await DeleteDiscountPreset(repo)((await all()).single.id!);
    expect(await all(), isEmpty);
  });

  test('a preset becomes an order discount with the same terms', () {
    const p = DiscountPreset(
        id: 1, label: 'Loyal', kind: DiscountKind.percent, value: 10);
    expect(
        p.toDiscount(),
        const OrderDiscount(
            label: 'Loyal', kind: DiscountKind.percent, value: 10));
    expect(discountValueLabel(DiscountKind.percent, 12.5), '12.5%');
    expect(discountValueLabel(DiscountKind.fixed, 50), '₱50');
  });

  group('DiscountPresetsBloc', () {
    DiscountPresetsBloc build() => DiscountPresetsBloc(
          getPresets: GetDiscountPresets(repo),
          savePreset: save,
          deletePreset: DeleteDiscountPreset(repo),
          reorderPresets: ReorderDiscountPresets(repo),
        );

    blocTest<DiscountPresetsBloc, DiscountPresetsState>(
      'loads an empty list',
      build: build,
      act: (b) => b.add(const LoadDiscountPresets()),
      expect: () => [const DiscountPresetsLoaded(presets: [])],
    );

    blocTest<DiscountPresetsBloc, DiscountPresetsState>(
      'saving reloads and says so',
      build: build,
      act: (b) => b.add(const SaveDiscountPresetEvent(
          label: 'Loyal', kind: DiscountKind.percent, value: 10)),
      expect: () => [
        isA<DiscountPresetsLoaded>()
            .having((s) => s.presets.single.label, 'preset', 'Loyal')
            .having((s) => s.message, 'message', 'Loyal added'),
      ],
    );

    blocTest<DiscountPresetsBloc, DiscountPresetsState>(
      'an invalid save keeps the list and reports the error',
      build: build,
      seed: () => const DiscountPresetsLoaded(presets: []),
      act: (b) => b.add(const SaveDiscountPresetEvent(
          label: 'Too much', kind: DiscountKind.percent, value: 150)),
      expect: () => [
        isA<DiscountPresetsLoaded>()
            .having((s) => s.isError, 'isError', isTrue)
            .having((s) => s.presets, 'presets', isEmpty),
      ],
    );

    blocTest<DiscountPresetsBloc, DiscountPresetsState>(
      'reorder moves at once and saves',
      setUp: () async {
        await save(label: 'A', kind: DiscountKind.fixed, value: 1);
        await save(label: 'B', kind: DiscountKind.fixed, value: 2);
      },
      build: build,
      act: (b) async {
        b.add(const LoadDiscountPresets());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        b.add(const ReorderDiscountPresetsEvent(1, 0));
      },
      skip: 1,
      expect: () => [
        isA<DiscountPresetsLoaded>()
            .having((s) => s.presets.map((p) => p.label), 'order', ['B', 'A']),
      ],
      verify: (_) async =>
          expect((await all()).map((p) => p.label), ['B', 'A']),
    );

    blocTest<DiscountPresetsBloc, DiscountPresetsState>(
      'delete names what went',
      setUp: () => save(label: 'A', kind: DiscountKind.fixed, value: 1),
      build: build,
      act: (b) async {
        b.add(const LoadDiscountPresets());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        b.add(DeleteDiscountPresetEvent((await all()).single.id!));
      },
      skip: 1,
      expect: () => [
        isA<DiscountPresetsLoaded>()
            .having((s) => s.presets, 'presets', isEmpty)
            .having((s) => s.message, 'message', 'A deleted'),
      ],
    );
  });
}
