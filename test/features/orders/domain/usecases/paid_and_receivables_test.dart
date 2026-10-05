import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_list_entry.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/get_order_list_entries.dart';
import 'package:craftbook/features/orders/domain/usecases/get_receivables.dart';
import 'package:craftbook/features/orders/domain/usecases/set_order_paid.dart';
import 'package:craftbook/features/orders/presentation/bloc/receivables_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrders extends Mock implements OrderRepository {}

class _MockEntries extends Mock implements GetOrderListEntries {}

void main() {
  late _MockOrders orders;
  late _MockEntries entries;

  Order order(int id,
          {String name = 'Ana',
          bool paid = false,
          double total = 100,
          OrderStatus status = OrderStatus.pending}) =>
      Order(
        id: id,
        customerName: name,
        orderDate: DateTime(2026, 9, id),
        shipByDate: DateTime(2026, 9, id),
        status: status,
        totalSales: total,
        totalMaterialCost: 0,
        channelFees: 0,
        shippingCost: 0,
        profit: 0,
        isPaid: paid,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  setUpAll(() => registerFallbackValue(<Order>[]));

  setUp(() {
    orders = _MockOrders();
    entries = _MockEntries();
    when(() => orders.setOrderPaid(any(), any()))
        .thenAnswer((_) async => const Success(null));
    when(() => entries(any())).thenAnswer((inv) async => Success([
          for (final o in inv.positionalArguments.first as List<Order>)
            OrderListEntry(order: o),
        ]));
  });

  group('SetOrderPaid', () {
    test('marks an unpaid order paid', () async {
      when(() => orders.getOrderById(1))
          .thenAnswer((_) async => Success(order(1)));
      expect(await SetOrderPaid(orders)(1, true), const Success<void>(null));
      verify(() => orders.setOrderPaid(1, true)).called(1);
    });

    test('does nothing when it already is', () async {
      when(() => orders.getOrderById(1))
          .thenAnswer((_) async => Success(order(1, paid: true)));
      expect(await SetOrderPaid(orders)(1, true), const Success<void>(null));
      verifyNever(() => orders.setOrderPaid(any(), any()));
    });

    test('refuses a cancelled order', () async {
      when(() => orders.getOrderById(1)).thenAnswer(
          (_) async => Success(order(1, status: OrderStatus.cancelled)));
      final result = await SetOrderPaid(orders)(1, true);
      expect((result as Error<void>).failure, isA<ValidationFailure>());
    });

    test('reports a missing order', () async {
      when(() => orders.getOrderById(1))
          .thenAnswer((_) async => const Success(null));
      final result = await SetOrderPaid(orders)(1, true);
      expect((result as Error<void>).failure, isA<NotFoundFailure>());
    });
  });

  group('GetReceivables', () {
    GetReceivables useCase() =>
        GetReceivables(orderRepository: orders, getOrderListEntries: entries);

    test('groups by customer, biggest debt first', () async {
      when(() => orders.getUnpaidOrders()).thenAnswer((_) async => Success([
            order(1, name: 'Ana', total: 100),
            order(2, name: 'Ben', total: 500),
            order(3, name: 'ana ', total: 50),
          ]));
      final r = (await useCase()() as Success<Receivables>).value;
      expect(r.groups.map((g) => (g.customerName, g.total)), [
        ('Ben', 500.0),
        ('Ana', 150.0),
      ]);
      expect(r.groups[1].entries.map((e) => e.order.id), [1, 3]);
      expect(r.total, 650);
      expect(r.orderCount, 3);
    });

    test('nothing unpaid is empty', () async {
      when(() => orders.getUnpaidOrders())
          .thenAnswer((_) async => const Success([]));
      expect((await useCase()() as Success<Receivables>).value.isEmpty, isTrue);
    });

    test('passes failures on', () async {
      when(() => orders.getUnpaidOrders())
          .thenAnswer((_) async => const Error(DatabaseFailure('locked')));
      expect(await useCase()(), isA<Error<Receivables>>());
    });

    blocTest<ReceivablesCubit, ReceivablesState>(
      'the cubit loads them',
      setUp: () => when(() => orders.getUnpaidOrders())
          .thenAnswer((_) async => Success([order(1)])),
      build: () => ReceivablesCubit(useCase()),
      act: (c) => c.load(),
      expect: () => [
        isA<ReceivablesLoaded>()
            .having((s) => s.receivables.total, 'total', 100),
      ],
    );

    blocTest<ReceivablesCubit, ReceivablesState>(
      'the cubit shows errors',
      setUp: () => when(() => orders.getUnpaidOrders())
          .thenAnswer((_) async => const Error(DatabaseFailure('locked'))),
      build: () => ReceivablesCubit(useCase()),
      act: (c) => c.load(),
      expect: () => [const ReceivablesError('locked')],
    );
  });
}
