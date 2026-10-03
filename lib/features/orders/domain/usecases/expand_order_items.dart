import '../../../../core/error/result.dart';
import '../../../products/domain/entities/bom_item.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../entities/order_item.dart';
import '../entities/order_material.dart';
import '../entities/order_product.dart';

/// What an order's items turn into: BOM products expand into materials
/// (at current unit cost), standalone products use their own stock.
class ExpandedOrder {
  final List<OrderMaterialInput> materials;
  final List<OrderProductInput> products;

  const ExpandedOrder(this.materials, this.products);

  /// Planned cost of everything, materials plus resold products.
  double get totalCost =>
      materials.fold<double>(0, (s, m) => s + m.actualQuantity * m.unitCost) +
      products.fold<double>(0, (s, p) => s + p.totalCost);
}

Future<ExpandedOrder> expandOrderItems(
  ProductRepository productRepository,
  List<OrderItemInput> items,
) async {
  final materials = <OrderMaterialInput>[];
  final products = <OrderProductInput>[];

  for (final item in items) {
    final productResult = await productRepository.getProductById(item.productId);
    final product = switch (productResult) {
      Success(:final value) => value,
      Error() => null,
    };

    if (product != null && product.isStandalone) {
      products.add(OrderProductInput(
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        unitCost: product.unitCost,
      ));
      continue;
    }

    final bomResult = await productRepository.getBomItems(item.productId);
    final bomItems = switch (bomResult) {
      Success(:final value) => value,
      Error() => <BomItem>[],
    };
    for (final bom in bomItems) {
      final needed = bom.quantityRequired * item.quantity;
      final index = materials.indexWhere((m) => m.materialId == bom.materialId);
      if (index >= 0) {
        final existing = materials[index];
        materials[index] = OrderMaterialInput(
          materialId: existing.materialId,
          materialName: existing.materialName,
          plannedQuantity: existing.plannedQuantity + needed,
          actualQuantity: existing.actualQuantity + needed,
          unitCost: existing.unitCost,
        );
      } else {
        materials.add(OrderMaterialInput(
          materialId: bom.materialId,
          materialName: bom.materialName,
          plannedQuantity: needed,
          actualQuantity: needed,
          unitCost: bom.materialUnitCost,
        ));
      }
    }
  }
  return ExpandedOrder(materials, products);
}
