import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Either<Failure, void>> call({
    required int id,
    String? name,
    String? description,
    double? sellPrice,
    bool? isActive,
    bool? isStandalone,
    int? alertLevel,
  }) {
    return repository.updateProduct(
      id: id,
      name: name,
      description: description,
      sellPrice: sellPrice,
      isActive: isActive,
      isStandalone: isStandalone,
      alertLevel: alertLevel,
    );
  }
}
