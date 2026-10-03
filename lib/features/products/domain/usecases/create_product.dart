import 'package:craftbook/core/error/result.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Result<Product?>> call({
    required String name,
    String? description,
    required double sellPrice,
    bool isStandalone = false,
    int initialQuantity = 0,
    double initialUnitCost = 0,
  }) async {
    if (name.trim().isEmpty) {
      return Error(const ValidationFailure('Product name is required'));
    }
    if (sellPrice <= 0) {
      return Error(const ValidationFailure('Sell price must be greater than 0'));
    }
    if (isStandalone && initialQuantity < 0) {
      return Error(const ValidationFailure('Initial quantity cannot be negative'));
    }
    if (isStandalone && initialUnitCost < 0) {
      return Error(const ValidationFailure('Unit cost cannot be negative'));
    }

    final result = await repository.createProduct(
      name: name.trim(),
      description: description?.trim(),
      sellPrice: sellPrice,
      isStandalone: isStandalone,
      initialQuantity: initialQuantity,
      initialUnitCost: initialUnitCost,
    );

    switch (result) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        return repository.getProductById(value);
    }
  }
}
