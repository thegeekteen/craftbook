import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

/// Base class for orders list events
abstract class OrdersListEvent extends Equatable {
  const OrdersListEvent();

  @override
  List<Object?> get props => [];
}

/// Load orders, optionally filtered by status
class LoadOrders extends OrdersListEvent {
  final OrderStatus? status;

  const LoadOrders({this.status});

  @override
  List<Object?> get props => [status];
}

/// Pack an order (deduct materials, update status)
class PackOrderEvent extends OrdersListEvent {
  final int orderId;

  const PackOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Ship an order (update status to shipped)
class ShipOrderEvent extends OrdersListEvent {
  final int orderId;

  const ShipOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
