import '../../../../core/error/result.dart';
import '../../../../core/utils/note_codec.dart';
import '../repositories/order_repository.dart';

/// Saves an order's note on its own, at any status.
class UpdateOrderNote {
  final OrderRepository repository;

  UpdateOrderNote(this.repository);

  /// A note with no words left in it is stored as null, so "has a note"
  /// checks elsewhere don't see an empty checklist as a note.
  Future<Result<void>> call(int orderId, String? note) {
    return repository.updateOrderNote(orderId, NoteCodec.isBlank(note) ? null : note);
  }
}
