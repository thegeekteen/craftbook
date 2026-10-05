import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';
import 'return_order_stock.dart';

/// Cancels an order that isn't already cancelled and gives its stock back:
/// reservations for a pending one, the used pieces for a packed or shipped
/// one (returned, or never sent). The order stays on record (out of
/// reports) and can then be deleted.
class CancelOrder {
  final OrderRepository orderRepository;
  final ReturnOrderStock returnOrderStock;

  CancelOrder({required this.orderRepository, required this.returnOrderStock});

  Future<Result<void>> call(int orderId) async {
    final orderResult = await orderRepository.getOrderById(orderId);
    switch (orderResult) {
      case Error(:final failure):
        return Error<void>(failure);
      case Success(:final value):
        final order = value;
        if (order == null) {
          return const Error<void>(NotFoundFailure('Order not found'));
        }
        switch (order.status) {
          case OrderStatus.cancelled:
            return const Error<void>(
                ValidationFailure('This order is already cancelled'));
          case OrderStatus.pending:
          case OrderStatus.packed:
          case OrderStatus.shipped:
            await returnOrderStock(order,
                reference: 'Restored from cancelled order');
            return orderRepository.cancelOrder(orderId);
        }
    }
  }
}
