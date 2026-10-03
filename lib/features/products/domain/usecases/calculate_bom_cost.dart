import 'package:craftbook/core/error/result.dart';

import '../repositories/product_repository.dart';

class CalculateBomCost {
  final ProductRepository repository;

  CalculateBomCost(this.repository);

  Future<Result<double>> call(int productId) async {
    return repository.calculateBomCost(productId);
  }
}
