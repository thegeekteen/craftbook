import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_list_entry.dart';
import 'package:craftbook/features/orders/domain/usecases/get_order_list_entries.dart';
import 'package:craftbook/features/orders/domain/usecases/get_orders.dart';
import 'package:craftbook/features/orders/presentation/bloc/orders_list_bloc.dart';
import 'package:craftbook/features/orders/presentation/bloc/orders_list_event.dart';
import 'package:craftbook/features/orders/presentation/bloc/orders_list_state.dart';

class MockGetOrders extends Mock implements GetOrders {}

class MockGetOrderListEntries extends Mock implements GetOrderListEntries {}

Order _order(int id, {OrderStatus status = OrderStatus.pending}) => Order(
      id: id,
      customerName: 'Customer $id',
      customerAddress: 'Cebu City',
      orderDate: DateTime(2026, 8, 26),
      shipByDate: DateTime(2026, 8, 28),
      status: status,
      channelId: 1,
      totalSales: 450,
      totalMaterialCost: 90,
      channelFees: 40,
      shippingCost: 0,
      profit: 320,
      createdAt: DateTime(2026, 8, 26),
      updatedAt: DateTime(2026, 8, 26),
    );

void main() {
  late MockGetOrders getOrders;
  late MockGetOrderListEntries getOrderListEntries;

  final orders = [_order(1), _order(2, status: OrderStatus.packed)];
  final entries = [
    OrderListEntry(
      order: orders[0],
      channelName: 'Shopee',
      lines: const [OrderLine(productName: 'Tulip', quantity: 2)],
    ),
    OrderListEntry(order: orders[1], channelName: 'Shopee'),
  ];

  setUpAll(() {
    registerFallbackValue(<Order>[]);
  });

  setUp(() {
    getOrders = MockGetOrders();
    getOrderListEntries = MockGetOrderListEntries();
  });

  OrdersListBloc build() => OrdersListBloc(
        getOrders: getOrders,
        getOrderListEntries: getOrderListEntries,
      );

  void stubSuccess() {
    when(() => getOrders()).thenAnswer((_) async => Success(orders));
    when(() => getOrderListEntries(any()))
        .thenAnswer((_) async => Success(entries));
  }

  test('initial state is OrdersListInitial', () {
    expect(build().state, isA<OrdersListInitial>());
  });

  blocTest<OrdersListBloc, OrdersListState>(
    'emits [Loading, Loaded] with decorated entries on success',
    setUp: stubSuccess,
    build: build,
    act: (bloc) => bloc.add(const LoadOrders()),
    expect: () => [isA<OrdersListLoading>(), OrdersListLoaded(entries)],
    verify: (_) {
      verify(() => getOrders()).called(1);
      verify(() => getOrderListEntries(orders)).called(1);
    },
  );

  blocTest<OrdersListBloc, OrdersListState>(
    'emits [Loading, Error] when getOrders fails and skips decoration',
    setUp: () => when(() => getOrders()).thenAnswer(
        (_) async => const Error(DatabaseFailure('read failed'))),
    build: build,
    act: (bloc) => bloc.add(const LoadOrders()),
    expect: () => [isA<OrdersListLoading>(), const OrdersListError('read failed')],
    verify: (_) => verifyNever(() => getOrderListEntries(any())),
  );

  blocTest<OrdersListBloc, OrdersListState>(
    'emits [Loading, Error] when getOrderListEntries fails',
    setUp: () {
      when(() => getOrders()).thenAnswer((_) async => Success(orders));
      when(() => getOrderListEntries(any())).thenAnswer(
          (_) async => const Error(DatabaseFailure('channels failed')));
    },
    build: build,
    act: (bloc) => bloc.add(const LoadOrders()),
    expect: () =>
        [isA<OrdersListLoading>(), const OrdersListError('channels failed')],
  );

  blocTest<OrdersListBloc, OrdersListState>(
    'reload while loaded does not emit Loading',
    setUp: stubSuccess,
    build: build,
    seed: () => const OrdersListLoaded([]),
    act: (bloc) => bloc.add(const LoadOrders()),
    expect: () => [OrdersListLoaded(entries)],
  );

  group('done completer', () {
    test('completes after a successful load', () async {
      stubSuccess();
      final bloc = build();
      final done = Completer<void>();
      bloc.add(LoadOrders(done: done));
      await done.future.timeout(const Duration(seconds: 1));
      expect(bloc.state, OrdersListLoaded(entries));
      await bloc.close();
    });

    test('completes after a failed load', () async {
      when(() => getOrders()).thenAnswer(
          (_) async => const Error(DatabaseFailure('x')));
      final bloc = build();
      final done = Completer<void>();
      bloc.add(LoadOrders(done: done));
      await done.future.timeout(const Duration(seconds: 1));
      expect(bloc.state, const OrdersListError('x'));
      await bloc.close();
    });
  });
}
