import '../../../../core/error/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Undoes a delete: the note comes back with its id and dates, so it lands in
/// the same place in the list.
class RestoreNote {
  final NoteRepository repository;

  RestoreNote(this.repository);

  Future<Result<void>> call(Note note) => repository.restoreNote(note);
}
