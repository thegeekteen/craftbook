import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/orders_table.dart';
import '../tables/order_items_table.dart';
import '../tables/order_materials_table.dart';
import '../tables/products_table.dart';
import '../tables/materials_table.dart';

part 'earnings_dao.g.dart';

/// Data Access Object for earnings calculations
@DriftAccessor(tables: [Orders, OrderItems, OrderMaterials, Products, Materials])
class EarningsDao extends DatabaseAccessor<AppDatabase> with _$EarningsDaoMixin {
  EarningsDao(AppDatabase db) : super(db);

  /// Get total earnings for date range
  Future<Map<String, dynamic>> getEarningsSummary(DateTime startDate, DateTime endDate) async {
    final shippedOrders = await (select(orders)
          ..where((t) =>
              t.shippedAt.isBiggerOrEqualValue(startDate) &
              t.shippedAt.isSmallerOrEqualValue(endDate) &
              t.status.equals('shipped')))
        .get();

    final totalSales = shippedOrders.fold<double>(0, (sum, order) => sum + order.totalSales);
    final totalMaterialCost = shippedOrders.fold<double>(0, (sum, order) => sum + order.totalMaterialCost);
    final totalChannelFees = shippedOrders.fold<double>(0, (sum, order) => sum + order.channelFees);
    final totalShippingCost = shippedOrders.fold<double>(0, (sum, order) => sum + order.shippingCost);
    final totalProfit = shippedOrders.fold<double>(0, (sum, order) => sum + order.profit);

    return {
      'totalSales': totalSales,
      'totalMaterialCost': totalMaterialCost,
      'totalChannelFees': totalChannelFees,
      'totalShippingCost': totalShippingCost,
      'totalProfit': totalProfit,
      'orderCount': shippedOrders.length,
    };
  }

  /// Get earnings by product for date range
  Future<List<Map<String, dynamic>>> getEarningsByProduct(DateTime startDate, DateTime endDate) async {
    final shippedOrders = await (select(orders)
          ..where((t) =>
              t.shippedAt.isBiggerOrEqualValue(startDate) &
              t.shippedAt.isSmallerOrEqualValue(endDate) &
              t.status.equals('shipped')))
        .get();

    final Map<int, Map<String, dynamic>> productEarnings = {};

    for (final order in shippedOrders) {
      final items = await (select(orderItems)..where((t) => t.orderId.equals(order.id))).get();
      
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

        final profitPerItem = order.profit / items.length;
        
        productEarnings[item.productId]!['quantity'] = 
            (productEarnings[item.productId]!['quantity'] as int) + item.quantity;
        productEarnings[item.productId]!['sales'] = 
            (productEarnings[item.productId]!['sales'] as double) + item.subtotal;
        productEarnings[item.productId]!['profit'] = 
            (productEarnings[item.productId]!['profit'] as double) + profitPerItem;
      }
    }

    return productEarnings.values.toList();
  }

  /// Get waste summary for date range, with per-material breakdown
  Future<Map<String, dynamic>> getWasteSummary(DateTime startDate, DateTime endDate) async {
    final allOrderMaterials = await (select(orderMaterials)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(startDate) &
                  t.createdAt.isSmallerOrEqualValue(endDate)))
        .get();

    final totalWaste = allOrderMaterials.fold<int>(0, (sum, m) => sum + m.wasteQuantity);
    final wasteCost = allOrderMaterials.fold<double>(0, (sum, m) => sum + (m.wasteQuantity * m.unitCost));

    // Group waste by materialId
    final Map<int, Map<String, dynamic>> byMaterial = {};
    for (final m in allOrderMaterials) {
      if (m.wasteQuantity <= 0) continue;
      byMaterial.putIfAbsent(m.materialId, () => {
        'materialId': m.materialId,
        'quantity': 0,
        'cost': 0.0,
      });
      byMaterial[m.materialId]!['quantity'] =
          (byMaterial[m.materialId]!['quantity'] as int) + m.wasteQuantity;
      byMaterial[m.materialId]!['cost'] =
          (byMaterial[m.materialId]!['cost'] as double) + (m.wasteQuantity * m.unitCost);
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
    wasteItems.sort((a, b) => (b['cost'] as double).compareTo(a['cost'] as double));

    return {
      'totalWasteQuantity': totalWaste,
      'totalWasteCost': wasteCost,
      'items': wasteItems,
    };
  }
}
