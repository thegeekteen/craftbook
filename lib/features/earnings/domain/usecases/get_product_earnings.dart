import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_earnings.dart';
import '../repositories/earnings_repository.dart';

class GetProductEarnings {
  final EarningsRepository repository;

  GetProductEarnings(this.repository);

  Future<Either<Failure, List<ProductEarnings>>> call(DateTime startDate, DateTime endDate) {
    return repository.getProductEarnings(startDate, endDate);
  }
}
