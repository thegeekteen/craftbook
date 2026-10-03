import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
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

  Future<Either<Failure, void>> call(int orderId) async {
    // Deduct material stock for BOM products
    final materialsResult = await orderRepository.getOrderMaterials(orderId);
    final materialsFailed = materialsResult.fold<bool>(
      (_) => true,
      (_) => false,
    );
    if (materialsFailed) {
      return Left(const DatabaseFailure('Failed to load order materials'));
    }

    await materialsResult.fold(
      (_) async {},
      (materials) async {
        for (final mat in materials) {
          await materialRepository.deductMaterials(
            mat.materialId,
            mat.actualQuantity,
          );
        }
      },
    );

    // Deduct product stock for standalone products
    final productsResult = await orderRepository.getOrderProducts(orderId);
    await productsResult.fold(
      (_) async {},
      (products) async {
        for (final prod in products) {
          await productRepository.deductProductStock(
            prod.productId,
            prod.quantity,
          );
        }
      },
    );

    return orderRepository.packOrder(orderId);
  }
}
