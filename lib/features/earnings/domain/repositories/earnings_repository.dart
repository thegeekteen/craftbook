import '../../../../core/error/result.dart';
import '../entities/earnings_summary.dart';
import '../entities/product_earnings.dart';
import '../entities/profit_trend.dart';

abstract class EarningsRepository {
  Future<Result<EarningsSummary>> getEarningsSummary(DateTime startDate, DateTime endDate);
  Future<Result<List<ProductEarnings>>> getProductEarnings(DateTime startDate, DateTime endDate);
  Future<Result<WasteSummary>> getWasteSummary(DateTime startDate, DateTime endDate);
  Future<Result<List<ProfitPoint>>> getCompletedOrderProfits(DateTime startDate, DateTime endDate);
  Future<Result<List<ProductOrderLine>>> getProductOrderLines(
      int productId, DateTime startDate, DateTime endDate);
}
