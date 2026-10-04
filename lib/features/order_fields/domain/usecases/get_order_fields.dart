import '../../../../core/error/result.dart';
import '../entities/order_field.dart';
import '../repositories/order_field_repository.dart';

class GetOrderFields {
  final OrderFieldRepository repository;

  GetOrderFields(this.repository);

  /// The order form asks only for active fields; settings shows all of them.
  Future<Result<List<OrderField>>> call({bool includeArchived = true}) =>
      repository.getFields(includeArchived: includeArchived);
}
