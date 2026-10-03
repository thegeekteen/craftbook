import 'package:equatable/equatable.dart';

import '../../domain/entities/order_material.dart';

/// Base class for order detail events
abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load the full detail for an order (order, items, materials)
class LoadOrderDetail extends OrderDetailEvent {
  final int orderId;

  const LoadOrderDetail(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Adjust the materials used for an order
class AdjustMaterials extends OrderDetailEvent {
  final int orderId;
  final List<OrderMaterialInput> materials;

  const AdjustMaterials({
    required this.orderId,
    required this.materials,
  });

  @override
  List<Object?> get props => [orderId, materials];
}

/// Pack the order (deduct materials, update status)
class PackOrderDetail extends OrderDetailEvent {
  final int orderId;

  const PackOrderDetail(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Ship the order (update status to shipped)
class ShipOrderDetail extends OrderDetailEvent {
  final int orderId;

  const ShipOrderDetail(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Delete the order (with stock reversal)
class DeleteOrderEvent extends OrderDetailEvent {
  final int orderId;

  const DeleteOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
