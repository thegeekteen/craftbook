import 'package:craftbook/core/error/result.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class ReceiveProductStock {
  final ProductRepository repository;

  ReceiveProductStock(this.repository);

  Future<Result<void>> call({
    required int productId,
    required int quantity,
    required double pricePerUnit,
    String? reference,
  }) async {
    if (quantity <= 0) {
      return Error(const ValidationFailure('Quantity must be greater than 0'));
    }
    if (pricePerUnit < 0) {
      return Error(const ValidationFailure('Price per unit cannot be negative'));
    }

    return repository.receiveProductStock(
      productId: productId,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      reference: reference,
    );
  }
}
