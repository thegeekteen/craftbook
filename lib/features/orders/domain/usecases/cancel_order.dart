import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';
import 'return_order_stock.dart';

/// Cancels a pending or packed order and gives its stock back. The order
/// stays on record (out of earnings) instead of disappearing.
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
          case OrderStatus.shipped:
            return const Error<void>(
                ValidationFailure('Shipped orders cannot be cancelled'));
          case OrderStatus.cancelled:
            return const Error<void>(
                ValidationFailure('This order is already cancelled'));
          case OrderStatus.pending:
          case OrderStatus.packed:
            await returnOrderStock(order,
                reference: 'Restored from cancelled order');
            return orderRepository.cancelOrder(orderId);
        }
    }
  }
}
