import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

/// Base class for orders list states
abstract class OrdersListState extends Equatable {
  const OrdersListState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class OrdersListInitial extends OrdersListState {}

/// Orders are being loaded
class OrdersListLoading extends OrdersListState {}

/// Orders loaded successfully
class OrdersListLoaded extends OrdersListState {
  final List<Order> orders;

  const OrdersListLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

/// Error occurred while loading orders
class OrdersListError extends OrdersListState {
  final String message;

  const OrdersListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// An order action (pack/ship) completed successfully
class OrderActionSuccess extends OrdersListState {
  final String message;

  const OrderActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
