import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../repositories/material_repository.dart';

/// Deletes a material nothing depends on. Only real use blocks it (a BOM or
/// an order); its own stock history goes with it, like a product's does.
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
    }

    final ordersResult = await materialRepository.isUsedInOrders(materialId);
    switch (ordersResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(value: final usedInOrders):
        if (usedInOrders) {
          return const Error(ValidationFailure(
            'Cannot delete material: used in past orders. Archive it instead.',
          ));
        }
    }

    return materialRepository.deleteMaterial(materialId);
  }
}
