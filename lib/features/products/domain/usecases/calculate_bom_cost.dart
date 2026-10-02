import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class CalculateBomCost {
  final ProductRepository repository;

  CalculateBomCost(this.repository);

  Future<Either<Failure, double>> call(int productId) async {
    return repository.calculateBomCost(productId);
  }
}
