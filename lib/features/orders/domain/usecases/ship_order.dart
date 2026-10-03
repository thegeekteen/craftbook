import '../../../../core/error/result.dart';
import '../repositories/order_repository.dart';

class ShipOrder {
  final OrderRepository repository;

  ShipOrder(this.repository);

  Future<Result<void>> call(int orderId) {
    return repository.shipOrder(orderId);
  }
}
