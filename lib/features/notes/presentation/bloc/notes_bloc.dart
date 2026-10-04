import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/restore_note.dart';
import '../../domain/usecases/set_note_pinned.dart';
import 'notes_event.dart';
import 'notes_state.dart';

/// The notebook list.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotes getNotes;
  final SetNotePinned setNotePinned;
  final DeleteNote deleteNote;
  final RestoreNote restoreNote;

  int _serial = 0;

  NotesBloc({
    required this.getNotes,
    required this.setNotePinned,
    required this.deleteNote,
    required this.restoreNote,
  }) : super(NotesInitial()) {
    on<LoadNotes>(_onLoad);
    on<SearchNotes>(_onSearch);
    on<ToggleNotePinEvent>(_onTogglePin);
    on<DeleteNoteEvent>(_onDelete);
    on<RestoreNoteEvent>(_onRestore);
  }

  String get _query => switch (state) {
        NotesLoaded(:final query) => query,
        _ => '',
      };

  Future<void> _onLoad(LoadNotes event, Emitter<NotesState> emit) async {
    if (state is! NotesLoaded) emit(NotesLoading());
    final result = await getNotes();
    switch (result) {
      case Error(:final failure):
        emit(NotesError(failure.message));
      case Success(:final value):
        emit(NotesLoaded(all: value, query: _query));
    }
  }

  void _onSearch(SearchNotes event, Emitter<NotesState> emit) {
    final current = state;
    if (current is NotesLoaded) emit(current.copyWith(query: event.query));
  }

  Future<void> _onTogglePin(
      ToggleNotePinEvent event, Emitter<NotesState> emit) async {
    final note = _find(event.id);
    if (note == null) return;
    final result = await setNotePinned(event.id, !note.isPinned);
    await _finish(emit, result, note.isPinned ? 'Unpinned' : 'Pinned to Today');
  }

  Future<void> _onDelete(
      DeleteNoteEvent event, Emitter<NotesState> emit) async {
    final note = _find(event.id);
    if (note == null) return;
    final result = await deleteNote(event.id);
    await _finish(emit, result, '${note.displayTitle} deleted', deleted: note);
  }

  Future<void> _onRestore(
      RestoreNoteEvent event, Emitter<NotesState> emit) async {
    final result = await restoreNote(event.note);
    await _finish(emit, result, '${event.note.displayTitle} restored');
  }

  /// Reloads after a successful action and reports how it went.
  Future<void> _finish(
    Emitter<NotesState> emit,
    Result<Object?> result,
    String successMessage, {
    Note? deleted,
  }) async {
    switch (result) {
      case Error(:final failure):
        final current = state;
        if (current is NotesLoaded) {
          emit(current.withMessage(failure.message, ++_serial, isError: true));
        } else {
          emit(NotesError(failure.message));
        }
      case Success():
        final loaded = await getNotes();
        switch (loaded) {
          case Error(:final failure):
            emit(NotesError(failure.message));
          case Success(:final value):
            emit(NotesLoaded(all: value, query: _query)
                .withMessage(successMessage, ++_serial, deleted: deleted));
        }
    }
  }

  Note? _find(int id) => switch (state) {
        NotesLoaded(:final all) => all.where((n) => n.id == id).firstOrNull,
        _ => null,
      };
}
