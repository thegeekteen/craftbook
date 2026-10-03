import '../../../../core/error/result.dart';
import '../entities/earnings_summary.dart';
import '../repositories/earnings_repository.dart';

class GetEarningsSummary {
  final EarningsRepository repository;

  GetEarningsSummary(this.repository);

  Future<Result<EarningsSummary>> call(DateTime startDate, DateTime endDate) {
    return repository.getEarningsSummary(startDate, endDate);
  }
}
