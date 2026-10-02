import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order_material.dart';
import '../repositories/order_repository.dart';

class PackOrder {
  final OrderRepository orderRepository;
  final MaterialRepository materialRepository;

  PackOrder({
    required this.orderRepository,
    required this.materialRepository,
  });

  Future<Either<Failure, void>> call(int orderId) async {
    final materialsResult = await orderRepository.getOrderMaterials(orderId);

    return materialsResult.fold(
      (failure) => Left(failure),
      (materials) async {
        for (final mat in materials) {
          final deductResult = await materialRepository.deductMaterials(
            mat.materialId,
            mat.actualQuantity,
          );
          if (deductResult.isLeft()) {
            return deductResult;
          }
        }

        return orderRepository.packOrder(orderId);
      },
    );
  }
}
