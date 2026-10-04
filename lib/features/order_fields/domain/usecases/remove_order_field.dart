import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../repositories/order_field_repository.dart';

enum RemoveOutcome { deleted, archived }

/// Deletes a field no order uses; archives one that orders still hold values
/// for, so past orders keep them.
class RemoveOrderField {
  final OrderFieldRepository repository;

  RemoveOrderField(this.repository);

  Future<Result<RemoveOutcome>> call(int id) async {
    final fieldResult = await repository.getField(id);
    switch (fieldResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        if (value == null) {
          return const Error(NotFoundFailure('Field not found'));
        }
        if (value.isUsed) {
          final result = await repository.setArchived(id, true);
          return switch (result) {
            Success() => const Success(RemoveOutcome.archived),
            Error(:final failure) => Error(failure),
          };
        }
        final result = await repository.deleteField(id);
        return switch (result) {
          Success() => const Success(RemoveOutcome.deleted),
          Error(:final failure) => Error(failure),
        };
    }
  }
}
