import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/orders_table.dart';
import '../tables/order_items_table.dart';
import '../tables/order_materials_table.dart';
import '../tables/products_table.dart';
import '../tables/materials_table.dart';

part 'earnings_dao.g.dart';

/// Raw rows for reports. The money is worked out by the repository, through
/// `OrderMoney`, so there is one formula for profit.
@DriftAccessor(
    tables: [Orders, OrderItems, OrderMaterials, Products, Materials])
class EarningsDao extends DatabaseAccessor<AppDatabase>
    with _$EarningsDaoMixin {
  EarningsDao(super.db);

  /// Packed or shipped orders completed within the range: packed orders by
  /// their packed date, shipped ones by their shipped date.
  Future<List<Order>> getCompletedOrders(
      DateTime startDate, DateTime endDate) async {
    final allCompleted = await (select(orders)
          ..where(
              (t) => t.status.equals('packed') | t.status.equals('shipped')))
        .get();

    return allCompleted.where((o) {
      final completionDate = completedAt(o);
      if (completionDate == null) return false;
      return !completionDate.isBefore(startDate) &&
          !completionDate.isAfter(endDate);
    }).toList();
  }

  static DateTime? completedAt(Order o) =>
      o.status == 'packed' ? o.packedAt : o.shippedAt;

  /// Item lines of each order, by order id.
  Future<Map<int, List<OrderItem>>> getItemsForOrders(
      Iterable<int> orderIds) async {
    final ids = orderIds.toSet();
    if (ids.isEmpty) return const {};
    final rows =
        await (select(orderItems)..where((t) => t.orderId.isIn(ids))).get();
    final byOrder = <int, List<OrderItem>>{};
    for (final r in rows) {
      byOrder.putIfAbsent(r.orderId, () => []).add(r);
    }
    return byOrder;
  }

  Future<Map<int, String>> getProductNames(Iterable<int> productIds) async {
    final ids = productIds.toSet();
    if (ids.isEmpty) return const {};
    final rows = await (select(products)..where((t) => t.id.isIn(ids))).get();
    return {for (final p in rows) p.id: p.name};
  }

  /// Material lines of the given orders.
  Future<List<OrderMaterial>> getMaterialsForOrders(
      Iterable<int> orderIds) async {
    final ids = orderIds.toSet();
    if (ids.isEmpty) return const [];
    return (select(orderMaterials)..where((t) => t.orderId.isIn(ids))).get();
  }

  Future<Map<int, String>> getMaterialNames(Iterable<int> materialIds) async {
    final ids = materialIds.toSet();
    if (ids.isEmpty) return const {};
    final rows = await (select(materials)..where((t) => t.id.isIn(ids))).get();
    return {for (final m in rows) m.id: m.name};
  }
}
