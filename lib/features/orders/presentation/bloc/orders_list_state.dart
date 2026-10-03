import 'package:equatable/equatable.dart';

import '../../domain/entities/order_list_entry.dart';

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
  final List<OrderListEntry> entries;

  const OrdersListLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

/// Error occurred while loading orders
class OrdersListError extends OrdersListState {
  final String message;

  const OrdersListError(this.message);

  @override
  List<Object?> get props => [message];
}
