import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../repositories/order_field_repository.dart';

/// Sets the order the active fields are asked for in.
class ReorderOrderFields {
  final OrderFieldRepository repository;

  ReorderOrderFields(this.repository);

  Future<Result<void>> call(List<int> orderedIds) async {
    if (orderedIds.toSet().length != orderedIds.length) {
      return const Error(ValidationFailure('A field appears twice'));
    }
    return repository.reorder(orderedIds);
  }
}
