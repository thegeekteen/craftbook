import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../products/domain/entities/bom_item.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order_item.dart';
import '../entities/order_material.dart';
import '../entities/order_product.dart';
import '../repositories/order_repository.dart';
import '../entities/order_discount.dart';
import '../entities/order_money.dart';
import 'calculate_order_profit.dart';

/// One thing an order will reserve: a material (BOM products) or a
/// standalone product's own stock.
class ReservationLine extends Equatable {
  final String name;
  final int quantity;

  /// Free pieces before this order reserves anything.
  final int available;
  final bool isProduct;

  const ReservationLine({
    required this.name,
    required this.quantity,
    required this.available,
    this.isProduct = false,
  });

  int get remaining => available - quantity;
  bool get isShort => quantity > available;
  bool get usesLast => !isShort && remaining == 0;

  @override
  List<Object?> get props => [name, quantity, available, isProduct];
}

/// What saving an order will do: the money split and the stock it takes.
class OrderPreview extends Equatable {
  final OrderMoney money;
  final List<ReservationLine> reservations;

  const OrderPreview({required this.money, required this.reservations});

  /// Items total before discounts.
  double get sales => money.itemsTotal;
  double get materialCost => money.materials;
  double get channelFees => money.fees;
  double get shippingCost => money.shipping;
  double get profit => money.profit;

  @override
  List<Object?> get props => [money, reservations];
}

/// Computes an [OrderPreview] the same way [CreateOrder] will: BOM products
/// expand into materials at their current unit cost, standalone products
/// use their own unit cost, fees and shipping come from the channel.
class PreviewOrder {
  final ProductRepository productRepository;
  final MaterialRepository materialRepository;
  final CalculateOrderProfit calculateOrderProfit;

  /// Only needed to preview an edit (see `excludeOrderId`).
  final OrderRepository? orderRepository;

  PreviewOrder({
    required this.productRepository,
    required this.materialRepository,
    required this.calculateOrderProfit,
    this.orderRepository,
  });

  /// With [excludeOrderId] (an order being edited) that order's own
  /// reservations count as free, since saving releases them first.
  Future<Result<OrderPreview>> call({
    required List<OrderItemInput> items,
    required int channelId,
    int? excludeOrderId,
    List<OrderDiscount> discounts = const [],
    OrderTax? tax,
  }) async {
    final ownMaterials = <int, int>{};
    final ownProducts = <int, int>{};
    if (excludeOrderId != null && orderRepository != null) {
      final mats = await orderRepository!.getOrderMaterials(excludeOrderId);
      if (mats case Error(:final failure)) return Error(failure);
      for (final m in (mats as Success<List<OrderMaterial>>).value) {
        ownMaterials[m.materialId] =
            (ownMaterials[m.materialId] ?? 0) + m.plannedQuantity;
      }
      final prods = await orderRepository!.getOrderProducts(excludeOrderId);
      if (prods case Error(:final failure)) return Error(failure);
      for (final p in (prods as Success<List<OrderProduct>>).value) {
        ownProducts[p.productId] = (ownProducts[p.productId] ?? 0) + p.quantity;
      }
    }

    final sales = items.fold<double>(0, (sum, i) => sum + i.subtotal);
    var materialCost = 0.0;
    final productLines = <ReservationLine>[];
    // materialId -> (name, needed, unitCost)
    final materialNeeds = <int, (String, int, double)>{};

    for (final item in items) {
      final productResult =
          await productRepository.getProductById(item.productId);
      if (productResult case Error(:final failure)) return Error(failure);
      final product = (productResult as Success).value;

      if (product != null && product.isStandalone) {
        materialCost += product.unitCost * item.quantity;
        productLines.add(ReservationLine(
          name: product.name,
          quantity: item.quantity,
          available: product.quantityFree + (ownProducts[product.id] ?? 0),
          isProduct: true,
        ));
        continue;
      }

      final bomResult = await productRepository.getBomItems(item.productId);
      if (bomResult case Error(:final failure)) return Error(failure);
      for (final BomItem bom in (bomResult as Success<List<BomItem>>).value) {
        final needed = bom.quantityRequired * item.quantity;
        final prev = materialNeeds[bom.materialId];
        materialNeeds[bom.materialId] = (
          bom.materialName,
          (prev?.$2 ?? 0) + needed,
          bom.materialUnitCost,
        );
        materialCost += needed * bom.materialUnitCost;
      }
    }

    final materialLines = <ReservationLine>[];
    for (final entry in materialNeeds.entries) {
      final (name, needed, _) = entry.value;
      final materialResult =
          await materialRepository.getMaterialById(entry.key);
      if (materialResult case Error(:final failure)) return Error(failure);
      final material = (materialResult as Success).value;
      materialLines.add(ReservationLine(
        name: name,
        quantity: needed,
        available:
            (material?.quantityFree ?? 0) + (ownMaterials[entry.key] ?? 0),
      ));
    }

    final profitResult = await calculateOrderProfit(
      totalSales: sales,
      totalMaterialCost: materialCost,
      channelId: channelId,
      shippingCost: 0,
      discounts: discounts,
      tax: tax,
    );
    if (profitResult case Error(:final failure)) return Error(failure);

    return Success(OrderPreview(
      money: (profitResult as Success<OrderMoney>).value,
      reservations: [...materialLines, ...productLines],
    ));
  }
}
