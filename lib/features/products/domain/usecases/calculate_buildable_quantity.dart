import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class CalculateBuildableQuantity {
  final ProductRepository repository;

  CalculateBuildableQuantity(this.repository);

  Future<Either<Failure, int>> call(int productId) async {
    return repository.calculateBuildableQuantity(productId);
  }
}
