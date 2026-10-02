import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/earnings_summary.dart';
import '../repositories/earnings_repository.dart';

class GetEarningsSummary {
  final EarningsRepository repository;

  GetEarningsSummary(this.repository);

  Future<Either<Failure, EarningsSummary>> call(DateTime startDate, DateTime endDate) {
    return repository.getEarningsSummary(startDate, endDate);
  }
}
