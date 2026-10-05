import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/orders_table.dart';
import '../tables/order_items_table.dart';
import '../tables/order_materials_table.dart';
import '../tables/products_table.dart';
import '../tables/materials_table.dart';
import '../tables/units_table.dart';

part 'earnings_dao.g.dart';

/// Raw rows for reports. The money is worked out by the repository, through
/// `OrderMoney`, so there is one formula for profit.
@DriftAccessor(
    tables: [Orders, OrderItems, OrderMaterials, Products, Materials, Units])
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

  /// Name and unit label for each product id.
  Future<Map<int, ({String name, String unit})>> getProductInfo(
      Iterable<int> productIds) async {
    final ids = productIds.toSet();
    if (ids.isEmpty) return const {};
    final rows = await (select(products).join([
      leftOuterJoin(units, units.id.equalsExp(products.unitId)),
    ])
          ..where(products.id.isIn(ids)))
        .get();
    return {
      for (final r in rows)
        r.readTable(products).id: (
          name: r.readTable(products).name,
          unit: r.readTableOrNull(units)?.label ?? '',
        ),
    };
  }

  /// Material lines of the given orders.
  Future<List<OrderMaterial>> getMaterialsForOrders(
      Iterable<int> orderIds) async {
    final ids = orderIds.toSet();
    if (ids.isEmpty) return const [];
    return (select(orderMaterials)..where((t) => t.orderId.isIn(ids))).get();
  }

  /// Name and unit label for each material id.
  Future<Map<int, ({String name, String unit})>> getMaterialInfo(
      Iterable<int> materialIds) async {
    final ids = materialIds.toSet();
    if (ids.isEmpty) return const {};
    final rows = await (select(materials).join([
      leftOuterJoin(units, units.id.equalsExp(materials.unitId)),
    ])
          ..where(materials.id.isIn(ids)))
        .get();
    return {
      for (final r in rows)
        r.readTable(materials).id: (
          name: r.readTable(materials).name,
          unit: r.readTableOrNull(units)?.label ?? '',
        ),
    };
  }
}
