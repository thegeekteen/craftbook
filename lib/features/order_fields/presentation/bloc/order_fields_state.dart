import 'package:equatable/equatable.dart';

import '../../domain/entities/order_field.dart';

abstract class OrderFieldsState extends Equatable {
  const OrderFieldsState();

  @override
  List<Object?> get props => [];
}

class OrderFieldsInitial extends OrderFieldsState {}

class OrderFieldsLoading extends OrderFieldsState {}

class OrderFieldsLoaded extends OrderFieldsState {
  /// Asked for on orders, in order.
  final List<OrderField> active;
  final List<OrderField> archived;

  /// Outcome of the last action, shown once. [serial] changes with every
  /// message so the same text twice still shows twice.
  final String? message;
  final bool isError;
  final int serial;

  const OrderFieldsLoaded({
    required this.active,
    required this.archived,
    this.message,
    this.isError = false,
    this.serial = 0,
  });

  bool get isEmpty => active.isEmpty && archived.isEmpty;

  OrderFieldsLoaded withMessage(String message, int serial,
          {bool isError = false}) =>
      OrderFieldsLoaded(
        active: active,
        archived: archived,
        message: message,
        isError: isError,
        serial: serial,
      );

  @override
  List<Object?> get props => [active, archived, message, isError, serial];
}

/// The list couldn't be loaded.
class OrderFieldsError extends OrderFieldsState {
  final String message;

  const OrderFieldsError(this.message);

  @override
  List<Object?> get props => [message];
}
