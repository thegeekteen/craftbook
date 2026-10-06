import '../../../../core/error/result.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Gives back what an order holds: a pending order's reservations are
/// released; a packed or shipped order's deducted pieces go back on the
/// shelf (a shipped one that's cancelled came back, or never went).
/// Shared by cancelling and deleting so the two can't drift apart.
class ReturnOrderStock {
  final OrderRepository orderRepository;
  final MaterialRepository materialRepository;
  final ProductRepository productRepository;

  ReturnOrderStock({
    required this.orderRepository,
    required this.materialRepository,
    required this.productRepository,
  });

  /// [reference] labels the restock in the stock history of a packed or
  /// shipped order.
  Future<void> call(Order order, {required String reference}) async {
    final orderId = order.id!;
    final packed = order.status == OrderStatus.packed ||
        order.status == OrderStatus.shipped;
    if (order.status != OrderStatus.pending && !packed) return;

    final materialsResult = await orderRepository.getOrderMaterials(orderId);
    if (materialsResult case Success(:final value)) {
      for (final mat in value) {
        if (packed) {
          await materialRepository.restoreDeductedMaterials(
            mat.materialId,
            mat.actualQuantity,
            reference: reference,
          );
        } else {
          await materialRepository.releaseReservedMaterials(
            mat.materialId,
            mat.actualQuantity,
          );
        }
      }
    }

    final productsResult = await orderRepository.getOrderProducts(orderId);
    if (productsResult case Success(:final value)) {
      for (final prod in value) {
        if (packed) {
          await productRepository.restoreDeductedProductStock(
            prod.productId,
            prod.quantity,
            reference: reference,
          );
        } else {
          await productRepository.releaseReservedProductStock(
            prod.productId,
            prod.quantity,
          );
        }
      }
    }
  }
}
