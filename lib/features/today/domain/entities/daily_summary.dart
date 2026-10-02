import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order.dart';

class DailySummary extends Equatable {
  final DateTime date;
  final List<Order> ordersDueToday;
  final List<Order> ordersToShipToday;
  final List<Order> newOrdersToday;
  final int lowStockCount;
  final int blockedProductCount;
  final int blockedOrderCount;

  const DailySummary({
    required this.date,
    required this.ordersDueToday,
    required this.ordersToShipToday,
    required this.newOrdersToday,
    required this.lowStockCount,
    required this.blockedProductCount,
    required this.blockedOrderCount,
  });

  int get totalOrders => ordersDueToday.length;
  bool get hasAlerts => lowStockCount > 0;

  @override
  List<Object?> get props => [
        date,
        ordersDueToday,
        ordersToShipToday,
        newOrdersToday,
        lowStockCount,
        blockedProductCount,
        blockedOrderCount,
      ];
}
