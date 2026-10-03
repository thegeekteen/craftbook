import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class AdjustProductStock {
  final ProductRepository repository;

  AdjustProductStock(this.repository);

  Future<Either<Failure, void>> call({
    required int productId,
    required int newQuantityOnHand,
  }) async {
    if (newQuantityOnHand < 0) {
      return Left(
        const ValidationFailure('Quantity on hand cannot be negative'),
      );
    }

    return repository.adjustProductStock(
      productId: productId,
      newQuantityOnHand: newQuantityOnHand,
    );
  }
}
