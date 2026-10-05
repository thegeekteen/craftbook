import '../../../../core/error/result.dart';
import '../entities/earnings_summary.dart';
import '../entities/report_filter.dart';
import '../repositories/earnings_repository.dart';

class GetWasteSummary {
  final EarningsRepository repository;

  GetWasteSummary(this.repository);

  Future<Result<WasteSummary>> call(DateTime startDate, DateTime endDate,
      {ReportFilter filter = ReportFilter.none}) {
    return repository.getWasteSummary(startDate, endDate, filter: filter);
  }
}
