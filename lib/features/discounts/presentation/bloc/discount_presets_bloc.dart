import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../orders/domain/entities/order_discount.dart';
import '../../domain/entities/discount_preset.dart';
import '../../domain/usecases/discount_preset_usecases.dart';

sealed class DiscountPresetsEvent extends Equatable {
  const DiscountPresetsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDiscountPresets extends DiscountPresetsEvent {
  const LoadDiscountPresets();
}

/// Adds a preset when [id] is null, otherwise edits it.
class SaveDiscountPresetEvent extends DiscountPresetsEvent {
  final int? id;
  final String label;
  final DiscountKind kind;
  final double value;

  const SaveDiscountPresetEvent({
    this.id,
    required this.label,
    required this.kind,
    required this.value,
  });

  @override
  List<Object?> get props => [id, label, kind, value];
}

class DeleteDiscountPresetEvent extends DiscountPresetsEvent {
  final int id;

  const DeleteDiscountPresetEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ReorderDiscountPresetsEvent extends DiscountPresetsEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderDiscountPresetsEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

sealed class DiscountPresetsState extends Equatable {
  const DiscountPresetsState();

  @override
  List<Object?> get props => [];
}

class DiscountPresetsLoading extends DiscountPresetsState {
  const DiscountPresetsLoading();
}

class DiscountPresetsLoaded extends DiscountPresetsState {
  final List<DiscountPreset> presets;

  /// Outcome of the last action, shown once. [serial] changes with every
  /// message so the same text twice still shows twice.
  final String? message;
  final bool isError;
  final int serial;

  const DiscountPresetsLoaded({
    required this.presets,
    this.message,
    this.isError = false,
    this.serial = 0,
  });

  DiscountPresetsLoaded withMessage(String message, int serial,
          {bool isError = false}) =>
      DiscountPresetsLoaded(
        presets: presets,
        message: message,
        isError: isError,
        serial: serial,
      );

  @override
  List<Object?> get props => [presets, message, isError, serial];
}

/// The list couldn't be loaded.
class DiscountPresetsError extends DiscountPresetsState {
  final String message;

  const DiscountPresetsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// The shop's discount presets.
class DiscountPresetsBloc
    extends Bloc<DiscountPresetsEvent, DiscountPresetsState> {
  final GetDiscountPresets getPresets;
  final SaveDiscountPreset savePreset;
  final DeleteDiscountPreset deletePreset;
  final ReorderDiscountPresets reorderPresets;

  int _serial = 0;

  DiscountPresetsBloc({
    required this.getPresets,
    required this.savePreset,
    required this.deletePreset,
    required this.reorderPresets,
  }) : super(const DiscountPresetsLoading()) {
    on<LoadDiscountPresets>(_onLoad);
    on<SaveDiscountPresetEvent>(_onSave);
    on<DeleteDiscountPresetEvent>(_onDelete);
    on<ReorderDiscountPresetsEvent>(_onReorder);
  }

  Future<void> _onLoad(
    LoadDiscountPresets event,
    Emitter<DiscountPresetsState> emit,
  ) async {
    final result = await getPresets();
    switch (result) {
      case Error(:final failure):
        emit(DiscountPresetsError(failure.message));
      case Success(:final value):
        emit(DiscountPresetsLoaded(presets: value));
    }
  }

  Future<void> _onSave(
    SaveDiscountPresetEvent event,
    Emitter<DiscountPresetsState> emit,
  ) async {
    final result = await savePreset(
      id: event.id,
      label: event.label,
      kind: event.kind,
      value: event.value,
    );
    final name = event.label.trim();
    await _finish(
        emit, result, event.id == null ? '$name added' : '$name saved');
  }

  Future<void> _onDelete(
    DeleteDiscountPresetEvent event,
    Emitter<DiscountPresetsState> emit,
  ) async {
    final current = state;
    final name = current is DiscountPresetsLoaded
        ? current.presets.where((p) => p.id == event.id).firstOrNull?.label
        : null;
    final result = await deletePreset(event.id);
    await _finish(emit, result, '${name ?? 'Discount'} deleted');
  }

  Future<void> _onReorder(
    ReorderDiscountPresetsEvent event,
    Emitter<DiscountPresetsState> emit,
  ) async {
    final current = state;
    if (current is! DiscountPresetsLoaded) return;
    final presets = [...current.presets];
    presets.insert(event.newIndex, presets.removeAt(event.oldIndex));

    // Moves at once; a failed save puts the list back.
    emit(DiscountPresetsLoaded(presets: presets));
    final result = await reorderPresets([for (final p in presets) p.id!]);
    if (result case Error(:final failure)) {
      emit(current.withMessage(failure.message, ++_serial, isError: true));
    }
  }

  /// Reloads after a successful action and reports how it went.
  Future<void> _finish(
    Emitter<DiscountPresetsState> emit,
    Result<Object?> result,
    String successMessage,
  ) async {
    switch (result) {
      case Error(:final failure):
        final current = state;
        if (current is DiscountPresetsLoaded) {
          emit(current.withMessage(failure.message, ++_serial, isError: true));
        } else {
          emit(DiscountPresetsError(failure.message));
        }
      case Success():
        final loaded = await getPresets();
        switch (loaded) {
          case Error(:final failure):
            emit(DiscountPresetsError(failure.message));
          case Success(:final value):
            emit(DiscountPresetsLoaded(presets: value)
                .withMessage(successMessage, ++_serial));
        }
    }
  }
}
