import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/domain/repositories/order_field_repository.dart';
import 'package:craftbook/features/order_fields/domain/usecases/get_order_fields.dart';
import 'package:craftbook/features/order_fields/domain/usecases/remove_order_field.dart';
import 'package:craftbook/features/order_fields/domain/usecases/reorder_order_fields.dart';
import 'package:craftbook/features/order_fields/domain/usecases/restore_order_field.dart';
import 'package:craftbook/features/order_fields/domain/usecases/save_order_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderFieldRepository extends Mock implements OrderFieldRepository {}

void main() {
  late MockOrderFieldRepository repo;

  const address = OrderField(id: 1, name: 'Address', type: OrderFieldType.text, usageCount: 3);
  const wrap = OrderField(id: 2, name: 'Wrap', type: OrderFieldType.choice, options: ['Kraft']);

  setUpAll(() => registerFallbackValue(const OrderField(name: '', type: OrderFieldType.text)));

  setUp(() {
    repo = MockOrderFieldRepository();
    when(() => repo.getFields()).thenAnswer((_) async => const Success([address, wrap]));
  });

  group('GetOrderFields', () {
    test('passes includeArchived through', () async {
      when(() => repo.getFields(includeArchived: false)).thenAnswer((_) async => const Success([wrap]));
      expect(await GetOrderFields(repo)(includeArchived: false), const Success([wrap]));
    });
  });

  group('SaveOrderField', () {
    late SaveOrderField save;
    setUp(() {
      save = SaveOrderField(repo);
      when(() => repo.createField(any())).thenAnswer((_) async => const Success(9));
      when(() => repo.updateField(any())).thenAnswer((_) async => const Success(null));
    });

    test('creates a trimmed field and returns its id', () async {
      expect(await save(name: '  Size ', type: OrderFieldType.text), const Success(9));
      verify(() => repo.createField(const OrderField(name: 'Size', type: OrderFieldType.text))).called(1);
    });

    test('cleans choices: trims, drops blanks and duplicates', () async {
      await save(name: 'Colour', type: OrderFieldType.choice, options: [' Red', '', 'red', 'Blue ']);
      verify(() => repo.createField(const OrderField(
            name: 'Colour',
            type: OrderFieldType.choice,
            options: ['Red', 'Blue'],
          ))).called(1);
    });

    test('multi-line only sticks to text fields', () async {
      await save(name: 'Count', type: OrderFieldType.number, isMultiline: true);
      verify(() => repo.createField(const OrderField(name: 'Count', type: OrderFieldType.number))).called(1);
    });

    test('rejects an empty name', () async {
      expect(
        await save(name: '  ', type: OrderFieldType.text),
        const Error<int>(ValidationFailure('Give the field a name')),
      );
    });

    test('rejects a choice field without choices', () async {
      expect(
        await save(name: 'Colour', type: OrderFieldType.choice, options: ['', ' ']),
        const Error<int>(ValidationFailure('Add at least one choice')),
      );
    });

    test('rejects a name another field has, ignoring case', () async {
      expect(
        await save(name: 'address', type: OrderFieldType.text),
        const Error<int>(ValidationFailure('There is already a field called address')),
      );
    });

    test('an edit may keep its own name', () async {
      expect(await save(id: 1, name: 'Address', type: OrderFieldType.text, isMultiline: true), const Success(1));
      verify(() => repo.updateField(const OrderField(
            id: 1,
            name: 'Address',
            type: OrderFieldType.text,
            isMultiline: true,
          ))).called(1);
    });

    test("a used field's type can't change", () async {
      expect(
        await save(id: 1, name: 'Address', type: OrderFieldType.number),
        const Error<int>(ValidationFailure("Type can't change once orders use the field")),
      );
      verifyNever(() => repo.updateField(any()));
    });

    test("an unused field's type can change", () async {
      expect(await save(id: 2, name: 'Wrap', type: OrderFieldType.text), const Success(2));
    });

    test('editing a missing field fails', () async {
      expect(
        await save(id: 99, name: 'Ghost', type: OrderFieldType.text),
        const Error<int>(NotFoundFailure('Field not found')),
      );
    });

    test('passes on a failure to read the existing fields', () async {
      when(() => repo.getFields()).thenAnswer((_) async => const Error(DatabaseFailure('disk')));
      expect(
        await save(name: 'Size', type: OrderFieldType.text),
        const Error<int>(DatabaseFailure('disk')),
      );
    });
  });

  group('RemoveOrderField', () {
    late RemoveOrderField remove;
    setUp(() {
      remove = RemoveOrderField(repo);
      when(() => repo.setArchived(any(), any())).thenAnswer((_) async => const Success(null));
      when(() => repo.deleteField(any())).thenAnswer((_) async => const Success(null));
    });

    test('archives a field orders use', () async {
      when(() => repo.getField(1)).thenAnswer((_) async => const Success(address));
      expect(await remove(1), const Success(RemoveOutcome.archived));
      verify(() => repo.setArchived(1, true)).called(1);
      verifyNever(() => repo.deleteField(any()));
    });

    test('deletes a field no order uses', () async {
      when(() => repo.getField(2)).thenAnswer((_) async => const Success(wrap));
      expect(await remove(2), const Success(RemoveOutcome.deleted));
      verify(() => repo.deleteField(2)).called(1);
    });

    test('fails for a missing field', () async {
      when(() => repo.getField(9)).thenAnswer((_) async => const Success(null));
      expect(await remove(9), const Error<RemoveOutcome>(NotFoundFailure('Field not found')));
    });

    test('passes on a delete failure', () async {
      when(() => repo.getField(2)).thenAnswer((_) async => const Success(wrap));
      when(() => repo.deleteField(2)).thenAnswer((_) async => const Error(DatabaseFailure('locked')));
      expect(await remove(2), const Error<RemoveOutcome>(DatabaseFailure('locked')));
    });
  });

  group('RestoreOrderField', () {
    test('un-archives the field', () async {
      when(() => repo.setArchived(1, false)).thenAnswer((_) async => const Success(null));
      expect(await RestoreOrderField(repo)(1), const Success<void>(null));
      verify(() => repo.setArchived(1, false)).called(1);
    });
  });

  group('ReorderOrderFields', () {
    test('saves the new order', () async {
      when(() => repo.reorder([2, 1])).thenAnswer((_) async => const Success(null));
      expect(await ReorderOrderFields(repo)([2, 1]), const Success<void>(null));
    });

    test('rejects a list naming a field twice', () async {
      expect(
        await ReorderOrderFields(repo)([1, 1]),
        const Error<void>(ValidationFailure('A field appears twice')),
      );
      verifyNever(() => repo.reorder(any()));
    });
  });
}
