import '../../../../core/error/result.dart';
import '../entities/earnings_summary.dart';
import '../entities/product_earnings.dart';

abstract class EarningsRepository {
  Future<Result<EarningsSummary>> getEarningsSummary(DateTime startDate, DateTime endDate);
  Future<Result<List<ProductEarnings>>> getProductEarnings(DateTime startDate, DateTime endDate);
  Future<Result<WasteSummary>> getWasteSummary(DateTime startDate, DateTime endDate);
}
