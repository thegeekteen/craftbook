import '../../../../core/error/result.dart';
import '../entities/order_material.dart';
import '../repositories/order_repository.dart';

class AdjustMaterialsUsed {
  final OrderRepository repository;

  AdjustMaterialsUsed(this.repository);

  Future<Result<void>> call(int orderId, List<OrderMaterialInput> materials) {
    return repository.adjustMaterialsUsed(orderId, materials);
  }
}
