import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../repositories/order_repository.dart';

class PackOrder {
  final OrderRepository orderRepository;
  final MaterialRepository materialRepository;
  final ProductRepository productRepository;

  PackOrder({
    required this.orderRepository,
    required this.materialRepository,
    required this.productRepository,
  });

  Future<Result<void>> call(int orderId) async {
    // Deduct material stock for BOM products
    final materialsResult = await orderRepository.getOrderMaterials(orderId);
    switch (materialsResult) {
      case Error():
        return const Error<void>(
            DatabaseFailure('Failed to load order materials'));
      case Success(:final value):
        for (final mat in value) {
          // Adjust keeps the reservation equal to the actual quantity, so
          // on-hand and promised both drop by what was used.
          await materialRepository.deductMaterials(
            mat.materialId,
            mat.actualQuantity,
            reserved: mat.actualQuantity,
          );
        }
    }

    // Deduct product stock for standalone products
    final productsResult = await orderRepository.getOrderProducts(orderId);
    switch (productsResult) {
      case Success(:final value):
        for (final prod in value) {
          await productRepository.deductProductStock(
            prod.productId,
            prod.quantity,
          );
        }
      case Error():
        break;
    }

    return orderRepository.packOrder(orderId);
  }
}
