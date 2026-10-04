import 'package:flutter/material.dart';

import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/order.dart';

extension OrderStatusLabel on OrderStatus {
  /// User-facing name. Pending orders are called "To pack" everywhere.
  String get label => switch (this) {
        OrderStatus.pending => 'To pack',
        OrderStatus.packed => 'Packed',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.cancelled => 'Cancelled',
      };
}

extension OrderUi on Order {
  /// Still waiting to be packed after its ship-by day has passed.
  bool get isOverdue {
    if (status != OrderStatus.pending) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(shipByDate.year, shipByDate.month, shipByDate.day);
    return due.isBefore(today);
  }

  /// Profit from components, never the stored value (business rule 5).
  double get liveProfit =>
      totalSales - totalMaterialCost - channelFees - shippingCost;
}

/// The one place order status maps to a pill. Overdue pending orders show
/// a red "Overdue" pill.
class OrderStatusPill extends StatelessWidget {
  final OrderStatus status;
  final bool overdue;

  const OrderStatusPill(
      {super.key, required this.status, this.overdue = false});

  factory OrderStatusPill.of(Order order, {Key? key}) =>
      OrderStatusPill(key: key, status: order.status, overdue: order.isOverdue);

  @override
  Widget build(BuildContext context) {
    if (overdue && status == OrderStatus.pending) {
      return const StatusPill(text: 'Overdue', type: StatusPillType.alert);
    }
    final type = switch (status) {
      OrderStatus.pending => StatusPillType.warning,
      OrderStatus.packed => StatusPillType.success,
      OrderStatus.shipped => StatusPillType.coin,
      OrderStatus.cancelled => StatusPillType.neutral,
    };
    return StatusPill(text: status.label, type: type);
  }
}

/// Dot colour for an order on calendars.
Color orderStatusColor(Order order,
    {required Color alert,
    required Color warn,
    required Color go,
    required Color coin,
    required Color muted}) {
  if (order.isOverdue) return alert;
  return switch (order.status) {
    OrderStatus.pending => warn,
    OrderStatus.packed => go,
    OrderStatus.shipped => coin,
    OrderStatus.cancelled => muted,
  };
}
