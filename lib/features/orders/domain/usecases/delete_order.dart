import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';
import 'return_order_stock.dart';

class DeleteOrder {
  final OrderRepository orderRepository;
  final ReturnOrderStock returnOrderStock;

  DeleteOrder({required this.orderRepository, required this.returnOrderStock});

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

        if (order.status == OrderStatus.shipped) {
          return const Error<void>(
            ValidationFailure('Shipped orders cannot be deleted'),
          );
        }

        // A cancelled order already gave its stock back when it was
        // cancelled; returning it again would double-count.
        await returnOrderStock(order, reference: 'Restored from deleted order');

        return orderRepository.deleteOrder(orderId);
    }
  }
}
