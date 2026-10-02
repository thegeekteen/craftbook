import 'package:equatable/equatable.dart';

/// Order item entity
class OrderItem extends Equatable {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        quantity,
        unitPrice,
        subtotal,
      ];
}

/// Input for creating an order item
class OrderItemInput extends Equatable {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItemInput({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  @override
  List<Object?> get props => [productId, productName, quantity, unitPrice];
}
