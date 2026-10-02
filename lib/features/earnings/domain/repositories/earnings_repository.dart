import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/earnings_summary.dart';
import '../entities/product_earnings.dart';

abstract class EarningsRepository {
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(DateTime startDate, DateTime endDate);
  Future<Either<Failure, List<ProductEarnings>>> getProductEarnings(DateTime startDate, DateTime endDate);
  Future<Either<Failure, WasteSummary>> getWasteSummary(DateTime startDate, DateTime endDate);
}
