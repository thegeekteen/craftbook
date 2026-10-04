import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../order_fields/domain/order_field_codec.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order_item.dart';
import '../repositories/order_repository.dart';
import 'expand_order_items.dart';

class CreateOrder {
  final OrderRepository orderRepository;
  final ProductRepository productRepository;
  final MaterialRepository materialRepository;

  CreateOrder({
    required this.orderRepository,
    required this.productRepository,
    required this.materialRepository,
  });

  Future<Result<int>> call({
    required String customerName,
    String? note,
    required DateTime orderDate,
    required DateTime shipByDate,
    required int channelId,
    required double totalSales,
    required double channelFees,
    required double shippingCost,
    required List<OrderItemInput> items,

    /// Custom field values by field id; blanks are dropped.
    Map<int, String> fieldValues = const {},
  }) async {
    if (customerName.trim().isEmpty) {
      return const Error<int>(ValidationFailure('Customer name is required'));
    }
    if (items.isEmpty) {
      return const Error<int>(ValidationFailure('At least one item is required'));
    }

    final expanded = await expandOrderItems(productRepository, items);
    final expandedMaterials = expanded.materials;
    final expandedProducts = expanded.products;

    // Planned cost: materials + standalone products
    final totalMaterialCost = expanded.totalCost;

    final profit = totalSales - totalMaterialCost - channelFees - shippingCost;

    final result = await orderRepository.createOrder(
      customerName: customerName.trim(),
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
      fieldValues: OrderFieldCodec.normalize(fieldValues),
    );

    switch (result) {
      case Error(:final failure):
        return Error<int>(failure);
      case Success(:final value):
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
        return Success<int>(value);
    }
  }
}
