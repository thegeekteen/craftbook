import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/orders_table.dart';
import '../tables/order_items_table.dart';
import '../tables/order_materials_table.dart';
import '../tables/products_table.dart';
import '../tables/materials_table.dart';

part 'earnings_dao.g.dart';

/// Data Access Object for earnings calculations
@DriftAccessor(
    tables: [Orders, OrderItems, OrderMaterials, Products, Materials])
class EarningsDao extends DatabaseAccessor<AppDatabase>
    with _$EarningsDaoMixin {
  EarningsDao(super.db);

  /// Get completed orders (packed or shipped) whose completion date falls within the range.
  /// Uses packedAt for packed orders, shippedAt for shipped orders.
  Future<List<Order>> _getCompletedOrders(
      DateTime startDate, DateTime endDate) async {
    final allCompleted = await (select(orders)
          ..where(
              (t) => t.status.equals('packed') | t.status.equals('shipped')))
        .get();

    return allCompleted.where((o) {
      final completionDate = o.status == 'packed' ? o.packedAt : o.shippedAt;
      if (completionDate == null) return false;
      return !completionDate.isBefore(startDate) &&
          !completionDate.isAfter(endDate);
    }).toList();
  }

  /// Get total earnings for date range
  Future<Map<String, dynamic>> getEarningsSummary(
      DateTime startDate, DateTime endDate) async {
    final completedOrders = await _getCompletedOrders(startDate, endDate);

    final totalSales =
        completedOrders.fold<double>(0, (sum, o) => sum + o.totalSales);
    final totalMaterialCost =
        completedOrders.fold<double>(0, (sum, o) => sum + o.totalMaterialCost);
    final totalChannelFees =
        completedOrders.fold<double>(0, (sum, o) => sum + o.channelFees);
    final totalShippingCost =
        completedOrders.fold<double>(0, (sum, o) => sum + o.shippingCost);

    // Recalculate profit from components — don't trust stored order.profit
    // which may be stale if materials were adjusted after creation.
    final totalProfit =
        totalSales - totalMaterialCost - totalChannelFees - totalShippingCost;

    return {
      'totalSales': totalSales,
      'totalMaterialCost': totalMaterialCost,
      'totalChannelFees': totalChannelFees,
      'totalShippingCost': totalShippingCost,
      'totalProfit': totalProfit,
      'orderCount': completedOrders.length,
    };
  }

  /// Get earnings by product for date range
  Future<List<Map<String, dynamic>>> getEarningsByProduct(
      DateTime startDate, DateTime endDate) async {
    final completedOrders = await _getCompletedOrders(startDate, endDate);

    final Map<int, Map<String, dynamic>> productEarnings = {};

    for (final order in completedOrders) {
      final items = await (select(orderItems)
            ..where((t) => t.orderId.equals(order.id)))
          .get();
      if (items.isEmpty) continue;

      // Recalculate this order's profit from components
      final orderProfit = order.totalSales -
          order.totalMaterialCost -
          order.channelFees -
          order.shippingCost;

      for (final item in items) {
        if (!productEarnings.containsKey(item.productId)) {
          final product = await (select(products)
                ..where((t) => t.id.equals(item.productId)))
              .getSingleOrNull();
          productEarnings[item.productId] = {
            'productId': item.productId,
            'productName': product?.name ?? '',
            'quantity': 0,
            'sales': 0.0,
            'profit': 0.0,
          };
        }

        // Allocate profit proportional to this item's share of order sales
        final salesShare =
            order.totalSales > 0 ? item.subtotal / order.totalSales : 0.0;
        final itemProfit = orderProfit * salesShare;

        productEarnings[item.productId]!['quantity'] =
            (productEarnings[item.productId]!['quantity'] as int) +
                item.quantity;
        productEarnings[item.productId]!['sales'] =
            (productEarnings[item.productId]!['sales'] as double) +
                item.subtotal;
        productEarnings[item.productId]!['profit'] =
            (productEarnings[item.productId]!['profit'] as double) + itemProfit;
      }
    }

    return productEarnings.values.toList();
  }

  /// Get waste summary for date range, with per-material breakdown.
  /// Only counts waste from packed or shipped orders.
  Future<Map<String, dynamic>> getWasteSummary(
      DateTime startDate, DateTime endDate) async {
    final completedOrders = await _getCompletedOrders(startDate, endDate);
    final completedOrderIds = completedOrders.map((o) => o.id).toSet();

    // Waste belongs to the period the order was completed in, like its
    // sales and profit; when the material row was created doesn't matter.
    final filtered = completedOrderIds.isEmpty
        ? <OrderMaterial>[]
        : await (select(orderMaterials)
              ..where((t) => t.orderId.isIn(completedOrderIds)))
            .get();

    final totalWaste = filtered.fold<int>(0, (sum, m) => sum + m.wasteQuantity);
    final wasteCost = filtered.fold<double>(
        0, (sum, m) => sum + (m.wasteQuantity * m.unitCost));

    // Group waste by materialId
    final Map<int, Map<String, dynamic>> byMaterial = {};
    for (final m in filtered) {
      if (m.wasteQuantity <= 0) continue;
      byMaterial.putIfAbsent(
          m.materialId,
          () => {
                'materialId': m.materialId,
                'quantity': 0,
                'cost': 0.0,
              });
      byMaterial[m.materialId]!['quantity'] =
          (byMaterial[m.materialId]!['quantity'] as int) + m.wasteQuantity;
      byMaterial[m.materialId]!['cost'] =
          (byMaterial[m.materialId]!['cost'] as double) +
              (m.wasteQuantity * m.unitCost);
    }

    // Resolve material names
    final wasteItems = <Map<String, dynamic>>[];
    for (final entry in byMaterial.values) {
      final matId = entry['materialId'] as int;
      final mat = await (select(materials)..where((t) => t.id.equals(matId)))
          .getSingleOrNull();
      wasteItems.add({
        'materialName': mat?.name ?? 'Unknown',
        'quantity': entry['quantity'] as int,
        'cost': entry['cost'] as double,
      });
    }

    // Sort by cost descending
    wasteItems
        .sort((a, b) => (b['cost'] as double).compareTo(a['cost'] as double));

    return {
      'totalWasteQuantity': totalWaste,
      'totalWasteCost': wasteCost,
      'items': wasteItems,
    };
  }

  /// Completion date and recomputed profit of every packed/shipped order
  /// completed in the range, for trend charts.
  Future<List<(DateTime, double)>> getCompletedOrderProfits(
      DateTime startDate, DateTime endDate) async {
    final completed = await _getCompletedOrders(startDate, endDate);
    return [
      for (final o in completed)
        (
          (o.status == 'packed' ? o.packedAt : o.shippedAt)!,
          o.totalSales - o.totalMaterialCost - o.channelFees - o.shippingCost,
        ),
    ];
  }

  /// Completed orders in the range that include [productId], with the
  /// quantity of that product and its share of the order's profit
  /// (allocated by sales, matching [getEarningsByProduct]).
  Future<List<Map<String, dynamic>>> getProductOrderLines(
      int productId, DateTime startDate, DateTime endDate) async {
    final completed = await _getCompletedOrders(startDate, endDate);
    if (completed.isEmpty) return const [];
    final byId = {for (final o in completed) o.id: o};
    final items = await (select(orderItems)
          ..where(
              (t) => t.productId.equals(productId) & t.orderId.isIn(byId.keys)))
        .get();

    final lines = <Map<String, dynamic>>[];
    for (final item in items) {
      final o = byId[item.orderId]!;
      final orderProfit =
          o.totalSales - o.totalMaterialCost - o.channelFees - o.shippingCost;
      final share = o.totalSales > 0 ? item.subtotal / o.totalSales : 0.0;
      lines.add({
        'orderId': o.id,
        'customerName': o.customerName,
        'quantity': item.quantity,
        'sales': item.subtotal,
        'profit': orderProfit * share,
        'completedAt': o.status == 'packed' ? o.packedAt : o.shippedAt,
      });
    }
    lines.sort((a, b) =>
        (b['completedAt'] as DateTime).compareTo(a['completedAt'] as DateTime));
    return lines;
  }
}
