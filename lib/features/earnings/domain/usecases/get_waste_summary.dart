import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/earnings_summary.dart';
import '../repositories/earnings_repository.dart';

class GetWasteSummary {
  final EarningsRepository repository;

  GetWasteSummary(this.repository);

  Future<Either<Failure, WasteSummary>> call(DateTime startDate, DateTime endDate) {
    return repository.getWasteSummary(startDate, endDate);
  }
}
