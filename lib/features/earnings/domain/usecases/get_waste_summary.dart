import '../../../../core/error/result.dart';
import '../entities/earnings_summary.dart';
import '../repositories/earnings_repository.dart';

class GetWasteSummary {
  final EarningsRepository repository;

  GetWasteSummary(this.repository);

  Future<Result<WasteSummary>> call(DateTime startDate, DateTime endDate) {
    return repository.getWasteSummary(startDate, endDate);
  }
}
