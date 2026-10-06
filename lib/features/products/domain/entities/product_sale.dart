import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order.dart';

/// One order line for a product, as seen from the product's side.
class ProductSale extends Equatable {
  final int orderId;
  final String customerName;
  final OrderStatus status;

  /// When the sale last moved: shipped, packed, or the order date.
  final DateTime date;
  final double quantity;
  final double unitPrice;
  final double subtotal;

  const ProductSale({
    required this.orderId,
    required this.customerName,
    required this.status,
    required this.date,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  @override
  List<Object?> get props =>
      [orderId, customerName, status, date, quantity, unitPrice, subtotal];
}
