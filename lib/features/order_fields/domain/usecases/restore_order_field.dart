import '../../../../core/error/result.dart';
import '../repositories/order_field_repository.dart';

/// Asks for an archived field on orders again, at the end of the list.
class RestoreOrderField {
  final OrderFieldRepository repository;

  RestoreOrderField(this.repository);

  Future<Result<void>> call(int id) => repository.setArchived(id, false);
}
