import '../../../../core/error/result.dart';
import '../entities/note.dart';

abstract class NoteRepository {
  /// Pinned first, then the most recently edited.
  Future<Result<List<Note>>> getNotes();
  Future<Result<List<Note>>> getPinnedNotes();
  Future<Result<Note?>> getNote(int id);

  /// Returns the new id.
  Future<Result<int>> createNote(Note note);

  /// Rewrites title, body and pin, and stamps the note as just edited.
  Future<Result<void>> updateNote(Note note);

  /// Doesn't count as an edit, so the note keeps its place among the others.
  Future<Result<void>> setPinned(int id, bool pinned);
  Future<Result<void>> deleteNote(int id);

  /// Puts a deleted note back exactly as it was, id and dates included.
  Future<Result<void>> restoreNote(Note note);
}
