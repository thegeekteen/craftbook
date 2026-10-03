import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../repositories/material_repository.dart';

class DeleteMaterial {
  final MaterialRepository materialRepository;
  final ProductRepository productRepository;

  DeleteMaterial({
    required this.materialRepository,
    required this.productRepository,
  });

  Future<Either<Failure, void>> call(int materialId) async {
    final productsResult =
        await productRepository.getProductsUsingMaterial(materialId);

    return productsResult.fold(
      (failure) => Left(failure),
      (products) async {
        if (products.isNotEmpty) {
          return Left(ValidationFailure(
            'Cannot delete material: used in ${products.length} product(s)',
          ));
        }

        final movementsResult =
            await materialRepository.getStockMovements(materialId);

        return movementsResult.fold(
          (failure) => Left(failure),
          (movements) async {
            if (movements.isNotEmpty) {
              return const Left(ValidationFailure(
                'Cannot delete material: has stock movement history',
              ));
            }

            return materialRepository.deleteMaterial(materialId);
          },
        );
      },
    );
  }
}
