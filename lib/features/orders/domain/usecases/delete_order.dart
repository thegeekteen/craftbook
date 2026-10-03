import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
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

  Future<Result<void>> call(int orderId) async {
    final orderResult = await orderRepository.getOrderById(orderId);

    switch (orderResult) {
      case Error(:final failure):
        return Error<void>(failure);
      case Success(:final value):
        final order = value;
        if (order == null) {
          return Error<void>(const NotFoundFailure('Order not found'));
        }

        if (order.status == OrderStatus.shipped) {
          return const Error<void>(
            ValidationFailure('Shipped orders cannot be deleted'),
          );
        }

        if (order.status == OrderStatus.pending ||
            order.status == OrderStatus.cancelled) {
          // Release reserved materials
          final materialsResult =
              await orderRepository.getOrderMaterials(orderId);
          switch (materialsResult) {
            case Success(:final value):
              for (final mat in value) {
                await materialRepository.releaseReservedMaterials(
                  mat.materialId,
                  mat.plannedQuantity,
                );
              }
            case Error():
              break;
          }

          // Release reserved standalone products
          final productsResult =
              await orderRepository.getOrderProducts(orderId);
          switch (productsResult) {
            case Success(:final value):
              for (final prod in value) {
                await productRepository.releaseReservedProductStock(
                  prod.productId,
                  prod.quantity,
                );
              }
            case Error():
              break;
          }
        } else if (order.status == OrderStatus.packed) {
          // Restore deducted materials
          final materialsResult =
              await orderRepository.getOrderMaterials(orderId);
          switch (materialsResult) {
            case Success(:final value):
              for (final mat in value) {
                await materialRepository.restoreDeductedMaterials(
                  mat.materialId,
                  mat.actualQuantity,
                );
              }
            case Error():
              break;
          }

          // Restore deducted standalone products
          final productsResult =
              await orderRepository.getOrderProducts(orderId);
          switch (productsResult) {
            case Success(:final value):
              for (final prod in value) {
                await productRepository.restoreDeductedProductStock(
                  prod.productId,
                  prod.quantity,
                );
              }
            case Error():
              break;
          }
        }

        return orderRepository.deleteOrder(orderId);
    }
  }
}
