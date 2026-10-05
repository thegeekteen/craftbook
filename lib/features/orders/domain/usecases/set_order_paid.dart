import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Marks an order paid or unpaid, at any stage except cancelled.
class SetOrderPaid {
  final OrderRepository orderRepository;

  SetOrderPaid(this.orderRepository);

  Future<Result<void>> call(int orderId, bool paid) async {
    final result = await orderRepository.getOrderById(orderId);
    switch (result) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        if (value == null) {
          return const Error(NotFoundFailure('Order not found'));
        }
        if (value.status == OrderStatus.cancelled) {
          return const Error(
              ValidationFailure('Cancelled orders have nothing to pay'));
        }
        if (value.isPaid == paid) return const Success(null);
        return orderRepository.setOrderPaid(orderId, paid);
    }
  }
}
