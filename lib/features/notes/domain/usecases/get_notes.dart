import '../../../../core/error/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Every note, pinned first, then the most recently edited.
class GetNotes {
  final NoteRepository repository;

  GetNotes(this.repository);

  Future<Result<List<Note>>> call() => repository.getNotes();
}
