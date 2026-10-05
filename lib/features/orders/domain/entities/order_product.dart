import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Persisted order product entry (standalone products in an order)
class OrderProduct extends Equatable {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;

  /// The product's unit label, looked up with its name. Not stored on the
  /// order, so renaming the unit reaches past orders too.
  final String productUnit;
  final double quantity;
  final double unitCost;

  double get totalCost => quantity * unitCost;

  const OrderProduct({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productUnit = AppConstants.defaultUnitLabel,
    required this.quantity,
    required this.unitCost,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        productUnit,
        quantity,
        unitCost,
      ];
}

/// Input DTO for creating order product entries
class OrderProductInput extends Equatable {
  final int productId;
  final String productName;
  final double quantity;
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
