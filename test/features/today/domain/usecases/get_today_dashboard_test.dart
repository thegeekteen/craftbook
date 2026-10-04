import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/earnings/domain/entities/earnings_summary.dart';
import 'package:craftbook/features/earnings/domain/repositories/earnings_repository.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_list_entry.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/get_order_list_entries.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:craftbook/features/today/domain/usecases/get_alert_summary.dart';
import 'package:craftbook/features/today/domain/usecases/get_today_dashboard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockEarningsRepository extends Mock implements EarningsRepository {}

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockGetOrderListEntries extends Mock implements GetOrderListEntries {}

void main() {
  final now = DateTime(2026, 10, 4, 15);
  final today = DateTime(2026, 10, 4);

  Order order(int id,
          {required DateTime shipBy,
          OrderStatus status = OrderStatus.pending,
          DateTime? placed}) =>
      Order(
        id: id,
        customerName: 'C$id',
        orderDate: placed ?? today.subtract(const Duration(days: 3)),
        shipByDate: shipBy,
        status: status,
        totalSales: 100,
        totalMaterialCost: 0,
        channelFees: 0,
        shippingCost: 0,
        profit: 0,
        createdAt: today,
        updatedAt: today,
      );

  late MockOrderRepository orders;
  late MockEarningsRepository earnings;
  late MockMaterialRepository materials;
  late MockGetOrderListEntries entries;
  late GetTodayDashboard useCase;

  setUpAll(() => registerFallbackValue(<Order>[]));

  setUp(() {
    orders = MockOrderRepository();
    earnings = MockEarningsRepository();
    materials = MockMaterialRepository();
    entries = MockGetOrderListEntries();
    useCase = GetTodayDashboard(
      orderRepository: orders,
      earningsRepository: earnings,
      getAlertSummary: GetAlertSummary(materials),
      getOrderListEntries: entries,
    );
    when(() => materials.getLowStockMaterials())
        .thenAnswer((_) async => const Success([]));
    when(() => entries(any())).thenAnswer((inv) async => Success([
          for (final o in inv.positionalArguments.first as List<Order>)
            OrderListEntry(order: o),
        ]));
  });

  test('counts due, overdue and placed orders, and recomputes week profit',
      () async {
    final overdue = order(1, shipBy: today.subtract(const Duration(days: 1)));
    final dueToday = order(2, shipBy: today);
    final packedToday = order(3, shipBy: today, status: OrderStatus.packed);
    final placedToday =
        order(4, shipBy: today.add(const Duration(days: 3)), placed: today);

    when(() => orders.getOpenOrdersDueBefore(DateTime(2026, 10, 5)))
        .thenAnswer((_) async => Success([overdue, dueToday, packedToday]));
    when(() => orders.getOrdersForDate(today))
        .thenAnswer((_) async => Success([placedToday, dueToday]));
    when(() => earnings.getEarningsSummary(DateTime(2026, 9, 28), any()))
        .thenAnswer((_) async => const Success(
              EarningsSummary(
                totalSales: 1000,
                totalMaterialCost: 300,
                totalChannelFees: 100,
                totalShippingCost: 50,
                totalProfit: 9999, // stale on purpose
                orderCount: 4,
              ),
            ));

    final result = await useCase(now);

    final d = (result as Success<TodayDashboard>).value;
    expect(d.due.map((e) => e.order.id), [1, 2, 3]);
    expect(d.placedToday.map((e) => e.order.id), [4, 2]);
    expect(d.toPackCount, 2);
    expect(d.overdueCount, 1);
    expect(d.weekProfit, 550);
    // One lookup for both lists, without duplicates.
    final passed =
        verify(() => entries(captureAny())).captured.single as List<Order>;
    expect(passed.map((o) => o.id).toSet(), {1, 2, 3, 4});
    expect(passed, hasLength(4));
  });

  test('fails when due orders cannot be loaded', () async {
    when(() => orders.getOpenOrdersDueBefore(any()))
        .thenAnswer((_) async => const Error(DatabaseFailure('x')));
    final result = await useCase(now);
    expect(result, isA<Error<TodayDashboard>>());
  });
}
