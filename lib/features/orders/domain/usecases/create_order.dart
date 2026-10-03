import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/bom_item.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order_item.dart';
import '../entities/order_material.dart';
import '../entities/order_product.dart';
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
    final expandedProducts = <OrderProductInput>[];
    final materialTotals = <int, double>{};

    for (final item in items) {
      // Check if product is standalone
      final productResult =
          await productRepository.getProductById(item.productId);
      final product = productResult.fold<dynamic>(
        (_) => null,
        (p) => p,
      );

      if (product != null && product.isStandalone) {
        // Standalone product: no BOM expansion, use product's own stock
        expandedProducts.add(OrderProductInput(
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unitCost: product.unitCost,
        ));
      } else {
        // BOM product: expand into materials
        final bomResult = await productRepository.getBomItems(item.productId);
        final bomItems = bomResult.fold(
          (_) => <BomItem>[],
          (items) => items,
        );

        for (final bom in bomItems) {
          final needed = bom.quantityRequired * item.quantity;
          materialTotals[bom.materialId] =
              (materialTotals[bom.materialId] ?? 0) + needed;

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
    }

    // Calculate total cost: materials + standalone products
    double totalMaterialCost = 0;
    for (final mat in expandedMaterials) {
      totalMaterialCost += mat.plannedQuantity * mat.unitCost;
    }
    for (final prod in expandedProducts) {
      totalMaterialCost += prod.totalCost;
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
      products: expandedProducts,
    );

    return result.fold(
      (failure) => Left(failure),
      (orderId) async {
        // Reserve material stock for BOM products
        for (final mat in expandedMaterials) {
          await materialRepository.reserveMaterials(
              mat.materialId, mat.plannedQuantity);
        }
        // Reserve product stock for standalone products
        for (final prod in expandedProducts) {
          await productRepository.reserveProductStock(
              prod.productId, prod.quantity);
        }
        return Right(orderId);
      },
    );
  }
}
