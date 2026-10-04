import '../../../../core/error/result.dart';
import '../entities/order_field.dart';

abstract class OrderFieldRepository {
  /// Fields by position, each with its usage count.
  Future<Result<List<OrderField>>> getFields({bool includeArchived = true});
  Future<Result<OrderField?>> getField(int id);

  /// Adds [field] at the end of the list; returns the new id.
  Future<Result<int>> createField(OrderField field);

  /// Rewrites name, type, multi-line and options. Position and archive state
  /// have their own methods.
  Future<Result<void>> updateField(OrderField field);
  Future<Result<void>> deleteField(int id);

  /// Archiving keeps the position; restoring moves the field to the end.
  Future<Result<void>> setArchived(int id, bool archived);

  /// Gives [ids] positions 0..n in list order.
  Future<Result<void>> reorder(List<int> ids);
}
