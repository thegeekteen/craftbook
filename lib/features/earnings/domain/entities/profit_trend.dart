import 'package:equatable/equatable.dart';

/// Profit of one completed order and when it was completed.
class ProfitPoint extends Equatable {
  final DateTime completedAt;
  final double profit;

  const ProfitPoint({required this.completedAt, required this.profit});

  @override
  List<Object?> get props => [completedAt, profit];
}

enum TrendGranularity { day, month }

/// Total profit for one bar of the trend chart.
class TrendBucket extends Equatable {
  final DateTime start;
  final double profit;

  const TrendBucket({required this.start, required this.profit});

  @override
  List<Object?> get props => [start, profit];
}

/// One completed order line for a product, with its allocated profit.
class ProductOrderLine extends Equatable {
  final int orderId;
  final String customerName;
  final int quantity;
  final double sales;
  final double profit;
  final DateTime completedAt;

  const ProductOrderLine({
    required this.orderId,
    required this.customerName,
    required this.quantity,
    required this.sales,
    required this.profit,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [orderId, customerName, quantity, sales, profit, completedAt];
}
