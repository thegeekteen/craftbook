import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_note.dart';
import '../../domain/usecases/save_note.dart';

class NoteEditState extends Equatable {
  /// The note as stored, or a blank one for a new note. Null while loading
  /// or after a failed load.
  final Note? note;
  final String? error;

  const NoteEditState({this.note, this.error});

  bool get isLoading => note == null && error == null;

  @override
  List<Object?> get props => [note, error];
}

/// Loads the note the editor opens on. Saving and deleting hand their result
/// straight back, since the page leaves on success and stays on failure.
class NoteEditCubit extends Cubit<NoteEditState> {
  final GetNote getNote;
  final SaveNote saveNote;
  final DeleteNote deleteNote;

  NoteEditCubit({
    required this.getNote,
    required this.saveNote,
    required this.deleteNote,
  }) : super(const NoteEditState());

  Future<void> load(int? id) async {
    if (id == null) {
      emit(const NoteEditState(note: Note()));
      return;
    }
    final result = await getNote(id);
    switch (result) {
      case Success(:final value):
        emit(NoteEditState(note: value));
      case Error(:final failure):
        emit(NoteEditState(error: failure.message));
    }
  }

  Future<Result<int>> save(Note note) => saveNote(note);

  Future<Result<void>> delete(int id) => deleteNote(id);
}
