import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class DeleteOrder {
  final OrderRepository orderRepository;
  final MaterialRepository materialRepository;

  DeleteOrder({
    required this.orderRepository,
    required this.materialRepository,
  });

  Future<Either<Failure, void>> call(int orderId) async {
    final orderResult = await orderRepository.getOrderById(orderId);

    return orderResult.fold(
      (failure) => Left(failure),
      (order) async {
        if (order == null) {
          return Left(const NotFoundFailure('Order not found'));
        }

        if (order.status == OrderStatus.shipped) {
          return const Left(
            ValidationFailure('Shipped orders cannot be deleted'),
          );
        }

        if (order.status == OrderStatus.pending ||
            order.status == OrderStatus.cancelled) {
          final materialsResult =
              await orderRepository.getOrderMaterials(orderId);
          await materialsResult.fold(
            (_) async {},
            (materials) async {
              for (final mat in materials) {
                await materialRepository.releaseReservedMaterials(
                  mat.materialId,
                  mat.plannedQuantity,
                );
              }
            },
          );
        } else if (order.status == OrderStatus.packed) {
          final materialsResult =
              await orderRepository.getOrderMaterials(orderId);
          await materialsResult.fold(
            (_) async {},
            (materials) async {
              for (final mat in materials) {
                await materialRepository.restoreDeductedMaterials(
                  mat.materialId,
                  mat.actualQuantity,
                );
              }
            },
          );
        }

        return orderRepository.deleteOrder(orderId);
      },
    );
  }
}
