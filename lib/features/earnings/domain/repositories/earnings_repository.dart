import '../../../../core/error/result.dart';
import '../entities/earnings_summary.dart';
import '../entities/product_earnings.dart';
import '../entities/profit_trend.dart';
import '../entities/report_filter.dart';

/// Reports over packed and shipped orders completed in a date range,
/// narrowed by an optional [ReportFilter].
abstract class EarningsRepository {
  Future<Result<EarningsSummary>> getEarningsSummary(
      DateTime startDate, DateTime endDate,
      {ReportFilter filter = ReportFilter.none});
  Future<Result<List<ProductEarnings>>> getProductEarnings(
      DateTime startDate, DateTime endDate,
      {ReportFilter filter = ReportFilter.none});
  Future<Result<WasteSummary>> getWasteSummary(
      DateTime startDate, DateTime endDate,
      {ReportFilter filter = ReportFilter.none});
  Future<Result<List<ProfitPoint>>> getCompletedOrderProfits(
      DateTime startDate, DateTime endDate,
      {ReportFilter filter = ReportFilter.none});
  Future<Result<List<ProductOrderLine>>> getProductOrderLines(
      int productId, DateTime startDate, DateTime endDate,
      {ReportFilter filter = ReportFilter.none});
}
