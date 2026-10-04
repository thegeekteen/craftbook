import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/note_codec.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Adds a note (when its id is null) or edits one. Returns the note's id.
class SaveNote {
  final NoteRepository repository;

  SaveNote(this.repository);

  Future<Result<int>> call(Note note) async {
    final title = note.title.trim();
    final blankBody = NoteCodec.isBlank(note.body);
    if (title.isEmpty && blankBody) {
      return const Error(ValidationFailure('Write something first'));
    }
    // An emptied body is stored as null, like order notes.
    final clean = note.copyWith(title: title, body: () => blankBody ? null : note.body);

    final id = clean.id;
    if (id == null) return repository.createNote(clean);
    final result = await repository.updateNote(clean);
    return switch (result) {
      Success() => Success(id),
      Error(:final failure) => Error(failure),
    };
  }
}
