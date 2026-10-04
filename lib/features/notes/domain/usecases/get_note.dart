import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNote {
  final NoteRepository repository;

  GetNote(this.repository);

  /// Fails with [NotFoundFailure] rather than returning null, so the editor
  /// can say the note is gone.
  Future<Result<Note>> call(int id) async {
    final result = await repository.getNote(id);
    return switch (result) {
      Success(value: final Note note) => Success(note),
      Success() => const Error(NotFoundFailure('This note was deleted')),
      Error(:final failure) => Error(failure),
    };
  }
}
