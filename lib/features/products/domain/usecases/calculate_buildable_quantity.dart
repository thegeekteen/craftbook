import 'package:craftbook/core/error/result.dart';

import '../repositories/product_repository.dart';

class CalculateBuildableQuantity {
  final ProductRepository repository;

  CalculateBuildableQuantity(this.repository);

  Future<Result<double>> call(int productId) async {
    return repository.calculateBuildableQuantity(productId);
  }
}
