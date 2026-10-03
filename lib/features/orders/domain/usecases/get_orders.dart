import '../../../../core/error/result.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrders {
  final OrderRepository repository;

  GetOrders(this.repository);

  Future<Result<List<Order>>> call({OrderStatus? status}) async {
    if (status != null) {
      return repository.getOrdersByStatus(status);
    }
    return repository.getAllOrders();
  }
}
