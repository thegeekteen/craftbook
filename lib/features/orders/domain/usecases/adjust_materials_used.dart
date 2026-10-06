import '../../../../core/error/result.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../../../../core/utils/quantity.dart';
import '../entities/order.dart';
import '../entities/order_material.dart';
import '../repositories/order_repository.dart';

/// Saves what was really used. While the order is pending its reservation
/// follows the actual quantity, so Stock's "promised" moves by the difference
/// and pack/cancel release exactly what is held.
class AdjustMaterialsUsed {
  final OrderRepository repository;
  final MaterialRepository materialRepository;

  AdjustMaterialsUsed(this.repository, this.materialRepository);

  Future<Result<void>> call(
      int orderId, List<OrderMaterialInput> materials) async {
    final orderResult = await repository.getOrderById(orderId);
    final pending = orderResult is Success<Order?> &&
        orderResult.value?.status == OrderStatus.pending;

    final oldActual = <int, double>{};
    if (pending) {
      final old = await repository.getOrderMaterials(orderId);
      if (old case Success(:final value)) {
        for (final m in value) {
          oldActual[m.materialId] = m.actualQuantity;
        }
      }
    }

    final saved = await repository.adjustMaterialsUsed(orderId, materials);
    if (!pending || saved is Error) return saved;

    for (final m in materials) {
      final delta = qty(m.actualQuantity - (oldActual[m.materialId] ?? 0));
      if (delta > 0) {
        await materialRepository.reserveMaterials(m.materialId, delta);
      } else if (delta < 0) {
        await materialRepository.releaseReservedMaterials(m.materialId, -delta);
      }
    }
    return saved;
  }
}
