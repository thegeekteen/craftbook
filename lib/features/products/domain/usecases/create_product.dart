import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Either<Failure, Product?>> call({
    required String name,
    String? description,
    required double sellPrice,
    bool isStandalone = false,
    int initialQuantity = 0,
    double initialUnitCost = 0,
  }) async {
    if (name.trim().isEmpty) {
      return Left(const ValidationFailure('Product name is required'));
    }
    if (sellPrice <= 0) {
      return Left(const ValidationFailure('Sell price must be greater than 0'));
    }
    if (isStandalone && initialQuantity < 0) {
      return Left(const ValidationFailure('Initial quantity cannot be negative'));
    }
    if (isStandalone && initialUnitCost < 0) {
      return Left(const ValidationFailure('Unit cost cannot be negative'));
    }

    final result = await repository.createProduct(
      name: name.trim(),
      description: description?.trim(),
      sellPrice: sellPrice,
      isStandalone: isStandalone,
      initialQuantity: initialQuantity,
      initialUnitCost: initialUnitCost,
    );

    return result.fold(
      (failure) => Left(failure),
      (id) async => repository.getProductById(id),
    );
  }
}
