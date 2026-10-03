import 'package:craftbook/core/error/result.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class AdjustProductStock {
  final ProductRepository repository;

  AdjustProductStock(this.repository);

  Future<Result<void>> call({
    required int productId,
    required int newQuantityOnHand,
  }) async {
    if (newQuantityOnHand < 0) {
      return const Error(
        ValidationFailure('Quantity on hand cannot be negative'),
      );
    }

    return repository.adjustProductStock(
      productId: productId,
      newQuantityOnHand: newQuantityOnHand,
    );
  }
}
