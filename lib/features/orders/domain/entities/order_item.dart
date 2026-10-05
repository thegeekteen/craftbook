import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Order item entity
class OrderItem extends Equatable {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;

  /// The product's current photo and unit, looked up with the name. Neither
  /// is stored on the order, so a renamed unit reaches past orders too.
  final Uint8List? productPhoto;
  final String unit;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productPhoto,
    this.unit = AppConstants.defaultUnitLabel,
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
        productPhoto,
        unit,
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

  /// For display while building the order; never saved with it.
  final Uint8List? photo;

  const OrderItemInput({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.photo,
  });

  double get subtotal => quantity * unitPrice;

  OrderItemInput copyWith({int? quantity}) => OrderItemInput(
        productId: productId,
        productName: productName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice,
        photo: photo,
      );

  @override
  List<Object?> get props =>
      [productId, productName, quantity, unitPrice, photo];
}
