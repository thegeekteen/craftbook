import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../repositories/material_repository.dart';

class DeleteMaterial {
  final MaterialRepository materialRepository;
  final ProductRepository productRepository;

  DeleteMaterial({
    required this.materialRepository,
    required this.productRepository,
  });

  Future<Result<void>> call(int materialId) async {
    final productsResult =
        await productRepository.getProductsUsingMaterial(materialId);

    switch (productsResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(value: final products):
        if (products.isNotEmpty) {
          return Error(ValidationFailure(
            'Cannot delete material: used in ${products.length} product(s)',
          ));
        }

        final movementsResult =
            await materialRepository.getStockMovements(materialId);

        switch (movementsResult) {
          case Error(:final failure):
            return Error(failure);
          case Success(value: final movements):
            if (movements.isNotEmpty) {
              return const Error(ValidationFailure(
                'Cannot delete material: has stock movement history',
              ));
            }

            return materialRepository.deleteMaterial(materialId);
        }
    }
  }
}
