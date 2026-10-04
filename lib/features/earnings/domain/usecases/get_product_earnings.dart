import '../../../../core/error/result.dart';
import '../entities/product_earnings.dart';
import '../repositories/earnings_repository.dart';

class GetProductEarnings {
  final EarningsRepository repository;

  GetProductEarnings(this.repository);

  Future<Result<List<ProductEarnings>>> call(
      DateTime startDate, DateTime endDate) {
    return repository.getProductEarnings(startDate, endDate);
  }
}
