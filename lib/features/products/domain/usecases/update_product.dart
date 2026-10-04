import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';

import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Result<void>> call({
    required int id,
    String? name,
    String? description,
    double? sellPrice,
    double? unitCost,
    bool? isArchived,
    bool? isStandalone,
    int? alertLevel,
  }) {
    if (name != null && name.trim().isEmpty) {
      return Future.value(const Error(ValidationFailure('Enter a name')));
    }
    if (sellPrice != null && sellPrice <= 0) {
      return Future.value(
          const Error(ValidationFailure('Enter a price above 0')));
    }
    if (unitCost != null && unitCost < 0) {
      return Future.value(
          const Error(ValidationFailure('Cost cannot be negative')));
    }
    if (alertLevel != null && alertLevel < 0) {
      return Future.value(
          const Error(ValidationFailure('Reorder level cannot be negative')));
    }
    return repository.updateProduct(
      id: id,
      name: name?.trim(),
      description: description,
      sellPrice: sellPrice,
      unitCost: unitCost,
      isArchived: isArchived,
      isStandalone: isStandalone,
      alertLevel: alertLevel,
    );
  }
}
