import 'package:craftbook/core/error/result.dart';

import '../repositories/product_repository.dart';

/// Pending orders per product id, for spotting products short for orders.
class GetPendingOrderCounts {
  final ProductRepository repository;

  GetPendingOrderCounts(this.repository);

  Future<Result<Map<int, int>>> call() => repository.getPendingOrderCounts();
}
