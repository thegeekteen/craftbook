import 'package:equatable/equatable.dart';

import '../../domain/entities/order_field.dart';

abstract class OrderFieldsEvent extends Equatable {
  const OrderFieldsEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderFields extends OrderFieldsEvent {
  const LoadOrderFields();
}

/// Adds a field when [id] is null, otherwise edits it.
class SaveOrderFieldEvent extends OrderFieldsEvent {
  final int? id;
  final String name;
  final OrderFieldType type;
  final bool isMultiline;
  final List<String> options;

  const SaveOrderFieldEvent({
    this.id,
    required this.name,
    required this.type,
    this.isMultiline = false,
    this.options = const [],
  });

  @override
  List<Object?> get props => [id, name, type, isMultiline, options];
}

/// Deletes the field, or archives it when orders hold values for it.
class RemoveOrderFieldEvent extends OrderFieldsEvent {
  final int id;

  const RemoveOrderFieldEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RestoreOrderFieldEvent extends OrderFieldsEvent {
  final int id;

  const RestoreOrderFieldEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// A drag in the active list: [newIndex] is where the field ends up.
class ReorderOrderFieldsEvent extends OrderFieldsEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderOrderFieldsEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
