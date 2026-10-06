import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Undoes a cancel. The order always comes back as to pack, even if it had
/// been packed: cancelling put its pieces back on the shelf, so it reserves
/// them again and gets packed (and its waste recorded) a second time.
class RestoreOrder {
  final OrderRepository orderRepository;
  final MaterialRepository materialRepository;
  final ProductRepository productRepository;

  RestoreOrder({
    required this.orderRepository,
    required this.materialRepository,
    required this.productRepository,
  });

  Future<Result<void>> call(int orderId) async {
    final orderResult = await orderRepository.getOrderById(orderId);
    final Order? order;
    switch (orderResult) {
      case Error(:final failure):
        return Error<void>(failure);
      case Success(:final value):
        order = value;
    }
    if (order == null) {
      return const Error<void>(NotFoundFailure('Order not found'));
    }
    if (order.status != OrderStatus.cancelled) {
      return const Error<void>(
          ValidationFailure('Only cancelled orders can be restored'));
    }

    final materialsResult = await orderRepository.getOrderMaterials(orderId);
    switch (materialsResult) {
      case Error(:final failure):
        return Error<void>(failure);
      case Success(:final value):
        for (final mat in value) {
          final reserved = await materialRepository.reserveMaterials(
              mat.materialId, mat.actualQuantity);
          if (reserved case Error(:final failure)) return Error<void>(failure);
        }
    }

    final productsResult = await orderRepository.getOrderProducts(orderId);
    switch (productsResult) {
      case Error(:final failure):
        return Error<void>(failure);
      case Success(:final value):
        for (final prod in value) {
          final reserved = await productRepository.reserveProductStock(
              prod.productId, prod.quantity);
          if (reserved case Error(:final failure)) return Error<void>(failure);
        }
    }

    return orderRepository.restoreOrder(orderId);
  }
}
