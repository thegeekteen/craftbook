import '../../../../core/error/result.dart';
import '../entities/product_earnings.dart';
import '../entities/report_filter.dart';
import '../repositories/earnings_repository.dart';

class GetProductEarnings {
  final EarningsRepository repository;

  GetProductEarnings(this.repository);

  Future<Result<List<ProductEarnings>>> call(
      DateTime startDate, DateTime endDate,
      {ReportFilter filter = ReportFilter.none}) {
    return repository.getProductEarnings(startDate, endDate, filter: filter);
  }
}
