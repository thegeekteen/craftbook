import '../../../../core/error/result.dart';
import '../entities/earnings_summary.dart';
import '../entities/report_filter.dart';
import '../repositories/earnings_repository.dart';

class GetEarningsSummary {
  final EarningsRepository repository;

  GetEarningsSummary(this.repository);

  Future<Result<EarningsSummary>> call(DateTime startDate, DateTime endDate,
      {ReportFilter filter = ReportFilter.none}) {
    return repository.getEarningsSummary(startDate, endDate, filter: filter);
  }
}
