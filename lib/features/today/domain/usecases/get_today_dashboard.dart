import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../earnings/domain/entities/earnings_summary.dart';
import '../../../earnings/domain/repositories/earnings_repository.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_list_entry.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../orders/domain/usecases/get_order_list_entries.dart';
import 'get_alert_summary.dart';

/// Everything the Today screen shows.
class TodayDashboard extends Equatable {
  /// Pending/packed orders shipping today or overdue, oldest first.
  final List<OrderListEntry> due;

  /// Orders placed today.
  final List<OrderListEntry> placedToday;
  final AlertSummary alerts;

  /// Profit from orders packed or shipped this week (Mon–Sun).
  final double weekProfit;

  /// The day this was worked out for; null means the phone's today.
  final DateTime? today;

  const TodayDashboard({
    required this.due,
    required this.placedToday,
    required this.alerts,
    required this.weekProfit,
    this.today,
  });

  int get toPackCount =>
      due.where((e) => e.order.status == OrderStatus.pending).length;

  int get overdueCount {
    final today = app_date.DateUtils.startOfDay(this.today ?? DateTime.now());
    return due
        .where((e) =>
            e.order.status == OrderStatus.pending &&
            e.order.shipByDate.isBefore(today))
        .length;
  }

  @override
  List<Object?> get props => [due, placedToday, alerts, weekProfit, today];
}

class GetTodayDashboard {
  final OrderRepository orderRepository;
  final EarningsRepository earningsRepository;
  final GetAlertSummary getAlertSummary;
  final GetOrderListEntries getOrderListEntries;

  GetTodayDashboard({
    required this.orderRepository,
    required this.earningsRepository,
    required this.getAlertSummary,
    required this.getOrderListEntries,
  });

  Future<Result<TodayDashboard>> call([DateTime? now]) async {
    final today = app_date.DateUtils.startOfDay(now ?? DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));

    final dueResult = await orderRepository.getOpenOrdersDueBefore(tomorrow);
    if (dueResult case Error(:final failure)) return Error(failure);
    final dueOrders = (dueResult as Success<List<Order>>).value;

    final placedResult = await orderRepository.getOrdersForDate(today);
    if (placedResult case Error(:final failure)) return Error(failure);
    // A cancelled order needs nothing doing, so it isn't news on Today.
    final placedOrders = (placedResult as Success<List<Order>>)
        .value
        .where((o) => o.status != OrderStatus.cancelled)
        .toList();

    final alertsResult = await getAlertSummary();
    if (alertsResult case Error(:final failure)) return Error(failure);
    final alerts = (alertsResult as Success<AlertSummary>).value;

    final weekResult = await earningsRepository.getEarningsSummary(
      app_date.DateUtils.startOfWeek(today),
      app_date.DateUtils.endOfWeek(today),
    );
    if (weekResult case Error(:final failure)) return Error(failure);
    final week = (weekResult as Success<EarningsSummary>).value;
    // Recompute from components rather than trusting a stored total.
    final weekProfit = week.profit;

    // One lookup for both lists so channels/items are fetched once.
    final allOrders = {
      for (final o in [...dueOrders, ...placedOrders]) o.id: o,
    }.values.toList();
    final entriesResult = await getOrderListEntries(allOrders);
    if (entriesResult case Error(:final failure)) return Error(failure);
    final byId = {
      for (final e in (entriesResult as Success<List<OrderListEntry>>).value)
        e.order.id: e,
    };

    return Success(TodayDashboard(
      due: [for (final o in dueOrders) byId[o.id]!],
      placedToday: [for (final o in placedOrders) byId[o.id]!],
      alerts: alerts,
      weekProfit: weekProfit,
      today: now == null ? null : today,
    ));
  }
}
