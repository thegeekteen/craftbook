import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/domain/usecases/get_order_fields.dart';
import 'package:craftbook/features/order_fields/domain/usecases/remove_order_field.dart';
import 'package:craftbook/features/order_fields/domain/usecases/reorder_order_fields.dart';
import 'package:craftbook/features/order_fields/domain/usecases/restore_order_field.dart';
import 'package:craftbook/features/order_fields/domain/usecases/save_order_field.dart';
import 'package:craftbook/features/order_fields/presentation/bloc/order_fields_bloc.dart';
import 'package:craftbook/features/order_fields/presentation/bloc/order_fields_event.dart';
import 'package:craftbook/features/order_fields/presentation/bloc/order_fields_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetOrderFields extends Mock implements GetOrderFields {}

class MockSaveOrderField extends Mock implements SaveOrderField {}

class MockRemoveOrderField extends Mock implements RemoveOrderField {}

class MockRestoreOrderField extends Mock implements RestoreOrderField {}

class MockReorderOrderFields extends Mock implements ReorderOrderFields {}

void main() {
  late MockGetOrderFields getFields;
  late MockSaveOrderField save;
  late MockRemoveOrderField remove;
  late MockRestoreOrderField restore;
  late MockReorderOrderFields reorder;

  const address = OrderField(
      id: 1, name: 'Address', type: OrderFieldType.text, usageCount: 2);
  const size =
      OrderField(id: 2, name: 'Size', type: OrderFieldType.text, position: 1);
  const card = OrderField(
      id: 3,
      name: 'Card',
      type: OrderFieldType.text,
      isArchived: true,
      usageCount: 1);

  const loaded = OrderFieldsLoaded(active: [address, size], archived: [card]);

  setUpAll(() => registerFallbackValue(OrderFieldType.text));

  setUp(() {
    getFields = MockGetOrderFields();
    save = MockSaveOrderField();
    remove = MockRemoveOrderField();
    restore = MockRestoreOrderField();
    reorder = MockReorderOrderFields();
    when(() => getFields())
        .thenAnswer((_) async => const Success([address, size, card]));
  });

  OrderFieldsBloc build() => OrderFieldsBloc(
        getOrderFields: getFields,
        saveOrderField: save,
        removeOrderField: remove,
        restoreOrderField: restore,
        reorderOrderFields: reorder,
      );

  void stubSave(Result<int> result) => when(() => save(
        id: any(named: 'id'),
        name: any(named: 'name'),
        type: any(named: 'type'),
        isMultiline: any(named: 'isMultiline'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => result);

  test('initial state is OrderFieldsInitial', () {
    expect(build().state, isA<OrderFieldsInitial>());
  });

  group('LoadOrderFields', () {
    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'splits fields into active and archived',
      build: build,
      act: (bloc) => bloc.add(const LoadOrderFields()),
      expect: () => [isA<OrderFieldsLoading>(), loaded],
    );

    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'emits an error when loading fails',
      setUp: () => when(() => getFields())
          .thenAnswer((_) async => const Error(DatabaseFailure('disk'))),
      build: build,
      act: (bloc) => bloc.add(const LoadOrderFields()),
      expect: () => [isA<OrderFieldsLoading>(), const OrderFieldsError('disk')],
    );
  });

  group('SaveOrderFieldEvent', () {
    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'reloads and confirms a new field',
      setUp: () => stubSave(const Success(4)),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const SaveOrderFieldEvent(
          name: ' Wrap ', type: OrderFieldType.choice, options: ['Kraft'])),
      expect: () => [loaded.withOutcome(OrderFieldOutcome.added, 'Wrap', 1)],
      verify: (_) => verify(() => save(
            id: null,
            name: ' Wrap ',
            type: OrderFieldType.choice,
            isMultiline: false,
            options: ['Kraft'],
          )).called(1),
    );

    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'confirms an edit as saved',
      setUp: () => stubSave(const Success(2)),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const SaveOrderFieldEvent(
          id: 2, name: 'Size', type: OrderFieldType.text)),
      expect: () => [loaded.withOutcome(OrderFieldOutcome.saved, 'Size', 1)],
    );

    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'keeps the list and shows a validation error',
      setUp: () => stubSave(const Error(
          ValidationFailure('There is already a field called Size'))),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(
          const SaveOrderFieldEvent(name: 'Size', type: OrderFieldType.text)),
      expect: () =>
          [loaded.withError('There is already a field called Size', 1)],
    );
  });

  group('RemoveOrderFieldEvent', () {
    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'says archived when orders use the field',
      setUp: () => when(() => remove(1))
          .thenAnswer((_) async => const Success(RemoveOutcome.archived)),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const RemoveOrderFieldEvent(1)),
      expect: () =>
          [loaded.withOutcome(OrderFieldOutcome.archived, 'Address', 1)],
    );

    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'says deleted otherwise',
      setUp: () => when(() => remove(2))
          .thenAnswer((_) async => const Success(RemoveOutcome.deleted)),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const RemoveOrderFieldEvent(2)),
      expect: () => [loaded.withOutcome(OrderFieldOutcome.deleted, 'Size', 1)],
    );

    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'shows a failure',
      setUp: () => when(() => remove(2))
          .thenAnswer((_) async => const Error(DatabaseFailure('locked'))),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const RemoveOrderFieldEvent(2)),
      expect: () => [loaded.withError('locked', 1)],
    );
  });

  group('RestoreOrderFieldEvent', () {
    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'reloads and confirms',
      setUp: () =>
          when(() => restore(3)).thenAnswer((_) async => const Success(null)),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const RestoreOrderFieldEvent(3)),
      expect: () => [loaded.withOutcome(OrderFieldOutcome.restored, 'Card', 1)],
    );
  });

  group('ReorderOrderFieldsEvent', () {
    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'moves the field straight away and saves the order',
      setUp: () => when(() => reorder([2, 1]))
          .thenAnswer((_) async => const Success(null)),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const ReorderOrderFieldsEvent(1, 0)),
      expect: () => [
        const OrderFieldsLoaded(active: [size, address], archived: [card])
      ],
      verify: (_) => verify(() => reorder([2, 1])).called(1),
    );

    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'puts the list back when saving fails',
      setUp: () => when(() => reorder(any()))
          .thenAnswer((_) async => const Error(DatabaseFailure('locked'))),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const ReorderOrderFieldsEvent(0, 1)),
      expect: () => [
        const OrderFieldsLoaded(active: [size, address], archived: [card]),
        loaded.withError('locked', 1),
      ],
    );

    blocTest<OrderFieldsBloc, OrderFieldsState>(
      'does nothing before the list has loaded',
      build: build,
      act: (bloc) => bloc.add(const ReorderOrderFieldsEvent(0, 1)),
      expect: () => <OrderFieldsState>[],
    );
  });
}
