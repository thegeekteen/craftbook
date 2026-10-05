import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart' show AppDatabase;
import 'package:craftbook/database/daos/material_dao.dart';
import 'package:craftbook/database/daos/product_dao.dart';
import 'package:craftbook/database/daos/unit_dao.dart';
import 'package:craftbook/features/stock/data/repositories/material_repository_impl.dart';
import 'package:craftbook/features/units/data/repositories/unit_repository_impl.dart';
import 'package:craftbook/features/units/domain/entities/unit_of_measure.dart';
import 'package:craftbook/features/units/domain/usecases/unit_usecases.dart';
import 'package:craftbook/features/units/presentation/bloc/units_bloc.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Units of measure: the rules on top of the database, and the bloc.
void main() {
  late AppDatabase db;
  late UnitRepositoryImpl repo;
  late MaterialRepositoryImpl materials;
  late SaveUnit save;
  late DeleteUnit remove;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = UnitRepositoryImpl(UnitDao(db));
    materials = MaterialRepositoryImpl(MaterialDao(db), ProductDao(db));
    save = SaveUnit(repo);
    remove = DeleteUnit(repo);
  });
  tearDown(() => db.close());

  T ok<T>(Result<T> r) => switch (r) {
        Success(:final value) => value,
        Error(:final failure) => throw StateError(failure.message),
      };

  Future<List<UnitOfMeasure>> all() async => ok(await repo.getUnits());

  Future<UnitOfMeasure> find(String label) async =>
      (await all()).firstWhere((u) => u.label == label);

  /// A material counted in [label], so the unit is in use.
  Future<void> useUnit(String label) async {
    final unit = await find(label);
    ok(await materials.createMaterial(
      name: 'Board',
      unitId: unit.id,
      packSize: 1,
      packPrice: 40,
      unitCost: 40,
      quantityOnHand: 0,
      alertLevel: 0,
    ));
  }

  group('SaveUnit', () {
    test('adds a trimmed label at the end of the list', () async {
      expect(await save(label: ' board '), const Success<void>(null));
      final added = (await all()).last;
      expect(
          (added.label, added.position, added.isDefault), ('board', 8, false));
    });

    test('renames by id and leaves the position alone', () async {
      final sheet = await find('sheet');
      await save(id: sheet.id, label: 'A4 sheet');
      final renamed = await find('A4 sheet');
      expect((renamed.id, renamed.position), (sheet.id, sheet.position));
      expect((await all()).where((u) => u.label == 'sheet'), isEmpty);
    });

    test('a unit may keep its own label', () async {
      final pc = await find('pc');
      expect(await save(id: pc.id, label: 'pc'), const Success<void>(null));
    });

    test('refuses a blank label without saving', () async {
      final result = await save(label: '   ');
      expect((result as Error<void>).failure, isA<ValidationFailure>());
      expect((await all()).length, 8);
    });

    test('refuses a label too long to sit next to a number', () async {
      final result = await save(label: 'x' * (maxUnitLabelLength + 1));
      expect(result, isA<Error<void>>());
    });

    test('refuses a duplicate, ignoring case', () async {
      final result = await save(label: 'PC');
      expect((result as Error<void>).failure.message,
          contains('already have a unit called "PC"'));
    });

    test('editing a missing unit is reported', () async {
      final result = await save(id: 99, label: 'Gone');
      expect((result as Error<void>).failure, isA<NotFoundFailure>());
    });
  });

  group('DeleteUnit', () {
    test('deletes an unused unit', () async {
      final ml = await find('ml');
      expect(await remove(ml.id!), const Success<void>(null));
      expect((await all()).where((u) => u.label == 'ml'), isEmpty);
    });

    test('refuses while a material is counted in it', () async {
      await useUnit('kg');
      final kg = await find('kg');
      final result = await remove(kg.id!);
      expect((result as Error<void>).failure.message,
          contains('1 material are counted in it'));
      expect((await all()).where((u) => u.label == 'kg'), hasLength(1));
    });

    test('refuses the last unit, so new items always have one', () async {
      for (final u in await all()) {
        if (u.label == 'pc') continue;
        await remove(u.id!);
      }
      final result = await remove((await find('pc')).id!);
      expect((result as Error<void>).failure.message,
          contains('Keep at least one unit'));
      expect(await all(), hasLength(1));
    });
  });

  test('ReorderUnits writes positions and refuses duplicates', () async {
    final reorder = ReorderUnits(repo);
    final ids = [for (final u in await all()) u.id!];
    expect(await reorder([ids[0], ids[0]]), isA<Error<void>>());
    await reorder(ids.reversed.toList());
    expect((await all()).map((u) => u.label).first, 'pack');
  });

  test('SetDefaultUnit moves the flag', () async {
    await SetDefaultUnit(repo)((await find('kg')).id!);
    expect((await all()).where((u) => u.isDefault).map((u) => u.label), ['kg']);
    expect(ok(await repo.getDefaultUnit())?.label, 'kg');
  });

  group('UnitsBloc', () {
    UnitsBloc build() => UnitsBloc(
          getUnits: GetUnits(repo),
          saveUnit: save,
          deleteUnit: remove,
          reorderUnits: ReorderUnits(repo),
          setDefaultUnit: SetDefaultUnit(repo),
        );

    blocTest<UnitsBloc, UnitsState>(
      'loads the seeded list',
      build: build,
      act: (b) => b.add(const LoadUnits()),
      expect: () => [
        isA<UnitsLoaded>().having(
            (s) => s.units.map((u) => u.label), 'labels', contains('pc')),
      ],
    );

    blocTest<UnitsBloc, UnitsState>(
      'saving reloads and says so',
      build: build,
      act: (b) => b.add(const SaveUnitEvent(label: 'board')),
      expect: () => [
        isA<UnitsLoaded>()
            .having((s) => s.units.last.label, 'added', 'board')
            .having((s) => s.message, 'message', 'board added'),
      ],
    );

    blocTest<UnitsBloc, UnitsState>(
      'a duplicate keeps the list and reports the error',
      seed: () => UnitsLoaded(units: const [UnitOfMeasure(id: 1, label: 'pc')]),
      build: build,
      act: (b) => b.add(const SaveUnitEvent(label: 'pc')),
      expect: () => [
        isA<UnitsLoaded>()
            .having((s) => s.isError, 'isError', isTrue)
            .having((s) => s.units, 'units', hasLength(1)),
      ],
    );

    blocTest<UnitsBloc, UnitsState>(
      'delete names what went',
      build: build,
      act: (b) async {
        b.add(const LoadUnits());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        b.add(DeleteUnitEvent((await find('ml')).id!));
      },
      skip: 1,
      expect: () => [
        isA<UnitsLoaded>()
            .having((s) => s.units.map((u) => u.label), 'labels',
                isNot(contains('ml')))
            .having((s) => s.message, 'message', 'ml deleted'),
      ],
    );

    blocTest<UnitsBloc, UnitsState>(
      'setting the default says what new items start on',
      build: build,
      act: (b) async {
        b.add(const LoadUnits());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        b.add(SetDefaultUnitEvent((await find('kg')).id!));
      },
      skip: 1,
      expect: () => [
        isA<UnitsLoaded>()
            .having((s) => s.message, 'message', 'New items start on kg'),
      ],
    );
  });
}
