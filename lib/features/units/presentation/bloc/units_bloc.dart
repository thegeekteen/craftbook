import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/unit_of_measure.dart';
import '../../domain/usecases/unit_usecases.dart';

sealed class UnitsEvent extends Equatable {
  const UnitsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUnits extends UnitsEvent {
  const LoadUnits();
}

/// Adds a unit when [id] is null, otherwise renames it.
class SaveUnitEvent extends UnitsEvent {
  final int? id;
  final String label;

  const SaveUnitEvent({this.id, required this.label});

  @override
  List<Object?> get props => [id, label];
}

class DeleteUnitEvent extends UnitsEvent {
  final int id;

  const DeleteUnitEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ReorderUnitsEvent extends UnitsEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderUnitsEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class SetDefaultUnitEvent extends UnitsEvent {
  final int id;

  const SetDefaultUnitEvent(this.id);

  @override
  List<Object?> get props => [id];
}

sealed class UnitsState extends Equatable {
  const UnitsState();

  @override
  List<Object?> get props => [];
}

class UnitsLoading extends UnitsState {
  const UnitsLoading();
}

class UnitsLoaded extends UnitsState {
  final List<UnitOfMeasure> units;

  /// Outcome of the last action, shown once. [serial] changes with every
  /// message so the same text twice still shows twice.
  final String? message;
  final bool isError;
  final int serial;

  const UnitsLoaded({
    required this.units,
    this.message,
    this.isError = false,
    this.serial = 0,
  });

  UnitsLoaded withMessage(String message, int serial, {bool isError = false}) =>
      UnitsLoaded(
        units: units,
        message: message,
        isError: isError,
        serial: serial,
      );

  @override
  List<Object?> get props => [units, message, isError, serial];
}

/// The list couldn't be loaded.
class UnitsError extends UnitsState {
  final String message;

  const UnitsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// The shop's units of measure.
class UnitsBloc extends Bloc<UnitsEvent, UnitsState> {
  final GetUnits getUnits;
  final SaveUnit saveUnit;
  final DeleteUnit deleteUnit;
  final ReorderUnits reorderUnits;
  final SetDefaultUnit setDefaultUnit;

  int _serial = 0;

  UnitsBloc({
    required this.getUnits,
    required this.saveUnit,
    required this.deleteUnit,
    required this.reorderUnits,
    required this.setDefaultUnit,
  }) : super(const UnitsLoading()) {
    on<LoadUnits>(_onLoad);
    on<SaveUnitEvent>(_onSave);
    on<DeleteUnitEvent>(_onDelete);
    on<ReorderUnitsEvent>(_onReorder);
    on<SetDefaultUnitEvent>(_onSetDefault);
  }

  Future<void> _onLoad(LoadUnits event, Emitter<UnitsState> emit) async {
    await _reload(emit);
  }

  Future<void> _onSave(SaveUnitEvent event, Emitter<UnitsState> emit) async {
    final result = await saveUnit(id: event.id, label: event.label);
    final name = event.label.trim();
    await _finish(
        emit, result, event.id == null ? '$name added' : '$name saved');
  }

  Future<void> _onDelete(
      DeleteUnitEvent event, Emitter<UnitsState> emit) async {
    final name = _labelOf(event.id);
    final result = await deleteUnit(event.id);
    await _finish(emit, result, '${name ?? 'Unit'} deleted');
  }

  Future<void> _onSetDefault(
    SetDefaultUnitEvent event,
    Emitter<UnitsState> emit,
  ) async {
    final result = await setDefaultUnit(event.id);
    await _finish(emit, result, 'New items start on ${_labelOf(event.id)}');
  }

  Future<void> _onReorder(
    ReorderUnitsEvent event,
    Emitter<UnitsState> emit,
  ) async {
    final current = state;
    if (current is! UnitsLoaded) return;
    final units = [...current.units];
    units.insert(event.newIndex, units.removeAt(event.oldIndex));

    // Moves at once; a failed save puts the list back.
    emit(UnitsLoaded(units: units));
    final result = await reorderUnits([for (final u in units) u.id!]);
    if (result case Error(:final failure)) {
      emit(current.withMessage(failure.message, ++_serial, isError: true));
    }
  }

  String? _labelOf(int id) {
    final current = state;
    if (current is! UnitsLoaded) return null;
    for (final unit in current.units) {
      if (unit.id == id) return unit.label;
    }
    return null;
  }

  /// Reloads after a successful action and reports how it went.
  Future<void> _finish(
    Emitter<UnitsState> emit,
    Result<Object?> result,
    String successMessage,
  ) async {
    switch (result) {
      case Error(:final failure):
        final current = state;
        if (current is UnitsLoaded) {
          emit(current.withMessage(failure.message, ++_serial, isError: true));
        } else {
          emit(UnitsError(failure.message));
        }
      case Success():
        await _reload(emit, message: successMessage);
    }
  }

  Future<void> _reload(Emitter<UnitsState> emit, {String? message}) async {
    final loaded = await getUnits();
    switch (loaded) {
      case Error(:final failure):
        emit(UnitsError(failure.message));
      case Success(:final value):
        emit(UnitsLoaded(
          units: value,
          message: message,
          serial: message == null ? 0 : ++_serial,
        ));
    }
  }
}
