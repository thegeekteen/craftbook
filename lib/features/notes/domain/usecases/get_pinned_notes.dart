import '../../../../core/error/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// The notes pinned to Today.
class GetPinnedNotes {
  final NoteRepository repository;

  GetPinnedNotes(this.repository);

  Future<Result<List<Note>>> call() => repository.getPinnedNotes();
}
