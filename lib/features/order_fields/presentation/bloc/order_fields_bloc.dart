import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/get_order_fields.dart';
import '../../domain/usecases/remove_order_field.dart';
import '../../domain/usecases/reorder_order_fields.dart';
import '../../domain/usecases/restore_order_field.dart';
import '../../domain/usecases/save_order_field.dart';
import 'order_fields_event.dart';
import 'order_fields_state.dart';

/// The settings list of custom order fields.
class OrderFieldsBloc extends Bloc<OrderFieldsEvent, OrderFieldsState> {
  final GetOrderFields getOrderFields;
  final SaveOrderField saveOrderField;
  final RemoveOrderField removeOrderField;
  final RestoreOrderField restoreOrderField;
  final ReorderOrderFields reorderOrderFields;

  int _serial = 0;

  OrderFieldsBloc({
    required this.getOrderFields,
    required this.saveOrderField,
    required this.removeOrderField,
    required this.restoreOrderField,
    required this.reorderOrderFields,
  }) : super(OrderFieldsInitial()) {
    on<LoadOrderFields>(_onLoad);
    on<SaveOrderFieldEvent>(_onSave);
    on<RemoveOrderFieldEvent>(_onRemove);
    on<RestoreOrderFieldEvent>(_onRestore);
    on<ReorderOrderFieldsEvent>(_onReorder);
  }

  Future<void> _onLoad(
    LoadOrderFields event,
    Emitter<OrderFieldsState> emit,
  ) async {
    if (state is! OrderFieldsLoaded) emit(OrderFieldsLoading());
    final loaded = await _fetch();
    switch (loaded) {
      case Error(:final failure):
        emit(OrderFieldsError(failure.message));
      case Success(:final value):
        emit(value);
    }
  }

  Future<void> _onSave(
    SaveOrderFieldEvent event,
    Emitter<OrderFieldsState> emit,
  ) async {
    final result = await saveOrderField(
      id: event.id,
      name: event.name,
      type: event.type,
      isMultiline: event.isMultiline,
      options: event.options,
    );
    await _finish(
      emit,
      result,
      event.id == null ? OrderFieldOutcome.added : OrderFieldOutcome.saved,
      event.name.trim(),
    );
  }

  Future<void> _onRemove(
    RemoveOrderFieldEvent event,
    Emitter<OrderFieldsState> emit,
  ) async {
    final name = _nameOf(event.id);
    final result = await removeOrderField(event.id);
    final outcome = switch (result) {
      Success(value: RemoveOutcome.archived) => OrderFieldOutcome.archived,
      _ => OrderFieldOutcome.deleted,
    };
    await _finish(emit, result, outcome, name);
  }

  Future<void> _onRestore(
    RestoreOrderFieldEvent event,
    Emitter<OrderFieldsState> emit,
  ) async {
    final result = await restoreOrderField(event.id);
    await _finish(emit, result, OrderFieldOutcome.restored, _nameOf(event.id));
  }

  Future<void> _onReorder(
    ReorderOrderFieldsEvent event,
    Emitter<OrderFieldsState> emit,
  ) async {
    final current = state;
    if (current is! OrderFieldsLoaded) return;
    final active = [...current.active];
    active.insert(event.newIndex, active.removeAt(event.oldIndex));

    // Moves at once; a failed save puts the list back.
    emit(OrderFieldsLoaded(active: active, archived: current.archived));
    final result = await reorderOrderFields([for (final f in active) f.id!]);
    if (result case Error(:final failure)) {
      emit(current.withError(failure.message, ++_serial));
    }
  }

  /// Reloads after a successful action and reports how it went.
  Future<void> _finish(
    Emitter<OrderFieldsState> emit,
    Result<Object?> result,
    OrderFieldOutcome outcome,
    String? subject,
  ) async {
    switch (result) {
      case Error(:final failure):
        final current = state;
        if (current is OrderFieldsLoaded) {
          emit(current.withError(failure.message, ++_serial));
        } else {
          emit(OrderFieldsError(failure.message));
        }
      case Success():
        final loaded = await _fetch();
        switch (loaded) {
          case Error(:final failure):
            emit(OrderFieldsError(failure.message));
          case Success(:final value):
            emit(value.withOutcome(outcome, subject, ++_serial));
        }
    }
  }

  Future<Result<OrderFieldsLoaded>> _fetch() async {
    final result = await getOrderFields();
    return switch (result) {
      Error(:final failure) => Error(failure),
      Success(:final value) => Success(OrderFieldsLoaded(
          active: [
            for (final f in value)
              if (!f.isArchived) f
          ],
          archived: [
            for (final f in value)
              if (f.isArchived) f
          ],
        )),
    };
  }

  /// Null when the field isn't in the list, so the page can name it itself.
  String? _nameOf(int id) {
    final current = state;
    if (current is! OrderFieldsLoaded) return null;
    return [...current.active, ...current.archived]
        .where((f) => f.id == id)
        .firstOrNull
        ?.name;
  }
}
