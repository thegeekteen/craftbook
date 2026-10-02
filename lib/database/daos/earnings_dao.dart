import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/orders_table.dart';
import '../tables/order_items_table.dart';
import '../tables/order_materials_table.dart';

part 'earnings_dao.g.dart';

/// Data Access Object for earnings calculations
@DriftAccessor(tables: [Orders, OrderItems, OrderMaterials])
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
          productEarnings[item.productId] = {
            'productId': item.productId,
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

  /// Get waste summary for date range
  Future<Map<String, dynamic>> getWasteSummary(DateTime startDate, DateTime endDate) async {
    final allOrderMaterials = await (select(orderMaterials)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(startDate) &
                  t.createdAt.isSmallerOrEqualValue(endDate)))
        .get();

    final totalWaste = allOrderMaterials.fold<int>(0, (sum, material) {
      return sum + material.wasteQuantity;
    });

    final wasteCost = allOrderMaterials.fold<double>(0, (sum, material) {
      return sum + (material.wasteQuantity * material.unitCost);
    });

    return {
      'totalWasteQuantity': totalWaste,
      'totalWasteCost': wasteCost,
    };
  }
}
