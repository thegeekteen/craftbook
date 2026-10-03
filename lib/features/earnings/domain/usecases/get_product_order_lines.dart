import '../../../../core/error/result.dart';
import '../entities/profit_trend.dart';
import '../repositories/earnings_repository.dart';

/// The completed orders behind a product's earnings for a period.
class GetProductOrderLines {
  final EarningsRepository repository;

  GetProductOrderLines(this.repository);

  Future<Result<List<ProductOrderLine>>> call(int productId, DateTime start, DateTime end) =>
      repository.getProductOrderLines(productId, start, end);
}
