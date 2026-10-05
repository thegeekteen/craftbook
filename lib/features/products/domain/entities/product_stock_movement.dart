import 'package:equatable/equatable.dart';

enum ProductStockMovementType {
  received,
  deducted,
  adjusted;

  String get displayName {
    switch (this) {
      case ProductStockMovementType.received:
        return 'Received';
      case ProductStockMovementType.deducted:
        return 'Deducted';
      case ProductStockMovementType.adjusted:
        return 'Adjusted';
    }
  }
}

class ProductStockMovement extends Equatable {
  final int? id;
  final int productId;
  final int? orderId;
  final ProductStockMovementType type;
  final double quantity;
  final double unitCost;
  final DateTime createdAt;
  final String? reference;

  const ProductStockMovement({
    this.id,
    required this.productId,
    this.orderId,
    required this.type,
    required this.quantity,
    required this.unitCost,
    required this.createdAt,
    this.reference,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        orderId,
        type,
        quantity,
        unitCost,
        createdAt,
        reference,
      ];
}
