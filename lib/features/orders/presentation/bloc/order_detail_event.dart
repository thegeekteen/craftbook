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

/// Mark the order paid or unpaid
class SetOrderPaidDetail extends OrderDetailEvent {
  final int orderId;
  final bool paid;

  const SetOrderPaidDetail(this.orderId, {required this.paid});

  @override
  List<Object?> get props => [orderId, paid];
}

/// Cancel the order and give its stock back
class CancelOrderDetail extends OrderDetailEvent {
  final int orderId;

  const CancelOrderDetail(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Bring a cancelled order back to pending and reserve its stock again
class RestoreOrderDetail extends OrderDetailEvent {
  final int orderId;

  const RestoreOrderDetail(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Store a new note for the order (edited, or a to-do ticked)
class SaveOrderNote extends OrderDetailEvent {
  final int orderId;
  final String? note;

  const SaveOrderNote({required this.orderId, required this.note});

  @override
  List<Object?> get props => [orderId, note];
}

/// Delete the order (with stock reversal)
class DeleteOrderEvent extends OrderDetailEvent {
  final int orderId;

  const DeleteOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
