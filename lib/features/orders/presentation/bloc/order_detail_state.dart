import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/channel.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_material.dart';

/// Base class for order detail states
abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class OrderDetailInitial extends OrderDetailState {}

/// Order detail is being loaded
class OrderDetailLoading extends OrderDetailState {}

/// Order detail loaded successfully
class OrderDetailLoaded extends OrderDetailState {
  final Order order;
  final List<OrderItem> items;
  final List<OrderMaterial> materials;
  final Channel? channel;

  const OrderDetailLoaded({
    required this.order,
    required this.items,
    required this.materials,
    this.channel,
  });

  @override
  List<Object?> get props => [order, items, materials, channel];
}

/// Error occurred while loading order detail
class OrderDetailError extends OrderDetailState {
  final String message;

  const OrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

/// An order action (pack/ship/adjust) completed successfully
class OrderDetailActionSuccess extends OrderDetailState {
  final String message;

  const OrderDetailActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Order was deleted successfully
class OrderDeleted extends OrderDetailState {}
