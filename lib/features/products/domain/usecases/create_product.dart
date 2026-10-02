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
  }) async {
    if (name.trim().isEmpty) {
      return Left(const ValidationFailure('Product name is required'));
    }
    if (sellPrice <= 0) {
      return Left(const ValidationFailure('Sell price must be greater than 0'));
    }

    final result = await repository.createProduct(
      name: name.trim(),
      description: description?.trim(),
      sellPrice: sellPrice,
    );

    return result.fold(
      (failure) => Left(failure),
      (id) async => repository.getProductById(id),
    );
  }
}
