import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/bom_item.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order_item.dart';
import '../entities/order_material.dart';
import '../repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository orderRepository;
  final ProductRepository productRepository;
  final MaterialRepository materialRepository;

  CreateOrder({
    required this.orderRepository,
    required this.productRepository,
    required this.materialRepository,
  });

  Future<Either<Failure, int>> call({
    required String customerName,
    required String customerAddress,
    String? note,
    required DateTime orderDate,
    required DateTime shipByDate,
    required int channelId,
    required double totalSales,
    required double channelFees,
    required double shippingCost,
    required List<OrderItemInput> items,
  }) async {
    if (customerName.trim().isEmpty) {
      return Left(const ValidationFailure('Customer name is required'));
    }
    if (items.isEmpty) {
      return Left(const ValidationFailure('At least one item is required'));
    }

    final expandedMaterials = <OrderMaterialInput>[];
    final materialTotals = <int, double>{};

    for (final item in items) {
      final bomResult = await productRepository.getBomItems(item.productId);
      final bomItems = bomResult.fold(
        (_) => <BomItem>[],
        (items) => items,
      );

      for (final bom in bomItems) {
        final needed = bom.quantityRequired * item.quantity;
        materialTotals[bom.materialId] = (materialTotals[bom.materialId] ?? 0) + needed;

        final existingIndex = expandedMaterials.indexWhere(
          (m) => m.materialId == bom.materialId,
        );

        if (existingIndex >= 0) {
          final existing = expandedMaterials[existingIndex];
          expandedMaterials[existingIndex] = OrderMaterialInput(
            materialId: existing.materialId,
            materialName: existing.materialName,
            plannedQuantity: existing.plannedQuantity + needed,
            actualQuantity: existing.actualQuantity + needed,
            unitCost: existing.unitCost,
          );
        } else {
          expandedMaterials.add(OrderMaterialInput(
            materialId: bom.materialId,
            materialName: bom.materialName,
            plannedQuantity: needed,
            actualQuantity: needed,
            unitCost: bom.materialUnitCost,
          ));
        }
      }
    }

    double totalMaterialCost = 0;
    for (final mat in expandedMaterials) {
      totalMaterialCost += mat.plannedQuantity * mat.unitCost;
    }

    final profit = totalSales - totalMaterialCost - channelFees - shippingCost;

    final result = await orderRepository.createOrder(
      customerName: customerName.trim(),
      customerAddress: customerAddress.trim(),
      note: note?.trim(),
      orderDate: orderDate,
      shipByDate: shipByDate,
      channelId: channelId,
      totalSales: totalSales,
      totalMaterialCost: totalMaterialCost,
      channelFees: channelFees,
      shippingCost: shippingCost,
      profit: profit,
      items: items,
      materials: expandedMaterials,
    );

    return result.fold(
      (failure) => Left(failure),
      (orderId) async {
        for (final mat in expandedMaterials) {
          await materialRepository.reserveMaterials(mat.materialId, mat.plannedQuantity);
        }
        return Right(orderId);
      },
    );
  }
}
