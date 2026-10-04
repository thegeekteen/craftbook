import '../../../../core/error/result.dart';
import '../repositories/note_repository.dart';

class SetNotePinned {
  final NoteRepository repository;

  SetNotePinned(this.repository);

  Future<Result<void>> call(int id, bool pinned) => repository.setPinned(id, pinned);
}
