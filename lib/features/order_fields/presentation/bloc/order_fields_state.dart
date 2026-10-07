import 'package:equatable/equatable.dart';

import '../../domain/entities/order_field.dart';

abstract class OrderFieldsState extends Equatable {
  const OrderFieldsState();

  @override
  List<Object?> get props => [];
}

/// What a field action did, so the page can say it in the user's language.
enum OrderFieldOutcome { added, saved, archived, deleted, restored }

class OrderFieldsInitial extends OrderFieldsState {}

class OrderFieldsLoading extends OrderFieldsState {}

class OrderFieldsLoaded extends OrderFieldsState {
  /// Asked for on orders, in order.
  final List<OrderField> active;
  final List<OrderField> archived;

  /// Outcome of the last action, shown once. [serial] changes with every
  /// message so the same text twice still shows twice. A success sets
  /// [outcome] and [subject] (the field's name, null when unknown); a failure
  /// sets [message] and [isError].
  final String? message;
  final OrderFieldOutcome? outcome;
  final String? subject;
  final bool isError;
  final int serial;

  const OrderFieldsLoaded({
    required this.active,
    required this.archived,
    this.message,
    this.outcome,
    this.subject,
    this.isError = false,
    this.serial = 0,
  });

  bool get isEmpty => active.isEmpty && archived.isEmpty;

  /// Whether there is something to tell the user.
  bool get hasNotice => message != null || outcome != null;

  OrderFieldsLoaded withError(String message, int serial) => OrderFieldsLoaded(
        active: active,
        archived: archived,
        message: message,
        isError: true,
        serial: serial,
      );

  OrderFieldsLoaded withOutcome(
          OrderFieldOutcome outcome, String? subject, int serial) =>
      OrderFieldsLoaded(
        active: active,
        archived: archived,
        outcome: outcome,
        subject: subject,
        serial: serial,
      );

  @override
  List<Object?> get props =>
      [active, archived, message, outcome, subject, isError, serial];
}

/// The list couldn't be loaded.
class OrderFieldsError extends OrderFieldsState {
  final String message;

  const OrderFieldsError(this.message);

  @override
  List<Object?> get props => [message];
}
