import '../../../../core/error/result.dart';
import '../repositories/note_repository.dart';

class DeleteNote {
  final NoteRepository repository;

  DeleteNote(this.repository);

  Future<Result<void>> call(int id) => repository.deleteNote(id);
}
