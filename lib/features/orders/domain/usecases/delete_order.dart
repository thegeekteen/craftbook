import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class DeleteOrder {
  final OrderRepository orderRepository;
  final MaterialRepository materialRepository;
  final ProductRepository productRepository;

  DeleteOrder({
    required this.orderRepository,
    required this.materialRepository,
    required this.productRepository,
  });

  Future<Either<Failure, void>> call(int orderId) async {
    final orderResult = await orderRepository.getOrderById(orderId);

    return orderResult.fold(
      (failure) => Left(failure),
      (order) async {
        if (order == null) {
          return Left(const NotFoundFailure('Order not found'));
        }

        if (order.status == OrderStatus.shipped) {
          return const Left(
            ValidationFailure('Shipped orders cannot be deleted'),
          );
        }

        if (order.status == OrderStatus.pending ||
            order.status == OrderStatus.cancelled) {
          // Release reserved materials
          final materialsResult =
              await orderRepository.getOrderMaterials(orderId);
          await materialsResult.fold(
            (_) async {},
            (materials) async {
              for (final mat in materials) {
                await materialRepository.releaseReservedMaterials(
                  mat.materialId,
                  mat.plannedQuantity,
                );
              }
            },
          );

          // Release reserved standalone products
          final productsResult =
              await orderRepository.getOrderProducts(orderId);
          await productsResult.fold(
            (_) async {},
            (products) async {
              for (final prod in products) {
                await productRepository.releaseReservedProductStock(
                  prod.productId,
                  prod.quantity,
                );
              }
            },
          );
        } else if (order.status == OrderStatus.packed) {
          // Restore deducted materials
          final materialsResult =
              await orderRepository.getOrderMaterials(orderId);
          await materialsResult.fold(
            (_) async {},
            (materials) async {
              for (final mat in materials) {
                await materialRepository.restoreDeductedMaterials(
                  mat.materialId,
                  mat.actualQuantity,
                );
              }
            },
          );

          // Restore deducted standalone products
          final productsResult =
              await orderRepository.getOrderProducts(orderId);
          await productsResult.fold(
            (_) async {},
            (products) async {
              for (final prod in products) {
                await productRepository.restoreDeductedProductStock(
                  prod.productId,
                  prod.quantity,
                );
              }
            },
          );
        }

        return orderRepository.deleteOrder(orderId);
      },
    );
  }
}
