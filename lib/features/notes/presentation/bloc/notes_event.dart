import 'package:equatable/equatable.dart';

import '../../domain/entities/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {
  const LoadNotes();
}

class SearchNotes extends NotesEvent {
  final String query;

  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleNotePinEvent extends NotesEvent {
  final int id;

  const ToggleNotePinEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteNoteEvent extends NotesEvent {
  final int id;

  const DeleteNoteEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Undo for a delete, from this list or from the editor.
class RestoreNoteEvent extends NotesEvent {
  final Note note;

  const RestoreNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}
