import 'package:equatable/equatable.dart';

/// Persisted order product entry (standalone products in an order)
class OrderProduct extends Equatable {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitCost;

  double get totalCost => quantity * unitCost;

  const OrderProduct({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        quantity,
        unitCost,
      ];
}

/// Input DTO for creating order product entries
class OrderProductInput extends Equatable {
  final int productId;
  final String productName;
  final int quantity;
  final double unitCost;

  double get totalCost => quantity * unitCost;

  const OrderProductInput({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
  });

  @override
  List<Object?> get props => [productId, productName, quantity, unitCost];
}
