import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/orders_table.dart';
import '../tables/order_items_table.dart';
import '../tables/order_materials_table.dart';
import '../tables/order_products_table.dart';
import '../tables/products_table.dart';
import '../tables/materials_table.dart';
import '../tables/product_stock_movements_table.dart';
import '../tables/order_fields_table.dart';

part 'order_dao.g.dart';

/// Data Access Object for orders
@DriftAccessor(tables: [Orders, OrderItems, OrderMaterials, OrderProducts, Products, Materials, ProductStockMovements, OrderFieldDefinitions, OrderFieldValues])
class OrderDao extends DatabaseAccessor<AppDatabase> with _$OrderDaoMixin {
  OrderDao(super.db);

  /// Get all orders
  Future<List<Order>> getAllOrders() {
    return select(orders).get();
  }

  /// Get order by ID
  Future<Order?> getOrderById(int id) {
    return (select(orders)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get orders by status
  Future<List<Order>> getOrdersByStatus(String status) {
    return (select(orders)..where((t) => t.status.equals(status))).get();
  }

  /// Get orders for today
  Future<List<Order>> getOrdersForToday(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return (select(orders)
          ..where((t) =>
              t.orderDate.isBiggerOrEqualValue(startOfDay) &
              t.orderDate.isSmallerThanValue(endOfDay)))
        .get();
  }

  /// Get orders within a date range (by shipByDate)
  Future<List<Order>> getOrdersForDateRange(DateTime start, DateTime end) {
    return (select(orders)
          ..where((t) =>
              t.shipByDate.isBiggerOrEqualValue(start) &
              t.shipByDate.isSmallerThanValue(end)))
        .get();
  }

  /// Pending or packed orders whose ship-by date is before [end].
  /// Covers both today's shipments and overdue ones.
  Future<List<Order>> getOpenOrdersDueBefore(DateTime end) {
    return (select(orders)
          ..where((t) =>
              (t.status.equals('pending') | t.status.equals('packed')) &
              t.shipByDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.shipByDate)]))
        .get();
  }

  /// Product lines for many orders in one query, as
  /// (orderId, productName, quantity).
  Future<List<(int, String, int)>> getOrderLines(List<int> orderIds) async {
    if (orderIds.isEmpty) return const [];
    final query = select(orderItems).join([
      innerJoin(products, products.id.equalsExp(orderItems.productId)),
    ])
      ..where(orderItems.orderId.isIn(orderIds))
      ..orderBy([OrderingTerm.asc(orderItems.id)]);
    final rows = await query.get();
    return [
      for (final r in rows)
        (
          r.readTable(orderItems).orderId,
          r.readTable(products).name,
          r.readTable(orderItems).quantity,
        ),
    ];
  }

  /// Get orders due for shipping
  Future<List<Order>> getOrdersDueForShipping(DateTime date) {
    return (select(orders)
          ..where((t) =>
              t.status.equals('packed') &
              t.shipByDate.isBiggerOrEqualValue(date)))
        .get();
  }

  /// Create new order
  Future<int> createOrder(OrdersCompanion order) {
    return into(orders).insert(order);
  }

  /// Update order
  Future<bool> updateOrder(Order order) {
    return update(orders).replace(order);
  }

  /// Update order status
  Future<int> updateOrderStatus(int orderId, String status) {
    return (update(orders)..where((t) => t.id.equals(orderId)))
        .write(OrdersCompanion(status: Value(status)));
  }

  /// Delete order
  Future<int> deleteOrder(int id) {
    return (delete(orders)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all order items for a given order
  Future<int> deleteOrderItemsByOrderId(int orderId) {
    return (delete(orderItems)..where((t) => t.orderId.equals(orderId))).go();
  }

  /// Delete all order materials for a given order
  Future<int> deleteOrderMaterialsByOrderId(int orderId) {
    return (delete(orderMaterials)..where((t) => t.orderId.equals(orderId)))
        .go();
  }

  /// Delete stock movements referencing a given order (via raw SQL)
  Future<int> deleteStockMovementsByOrderId(int orderId) {
    return customUpdate(
      'DELETE FROM stock_movements WHERE order_id = ?',
      variables: [Variable.withInt(orderId)],
    );
  }

  /// Delete product stock movements referencing a given order
  Future<int> deleteProductStockMovementsByOrderId(int orderId) {
    return (delete(productStockMovements)
          ..where((t) => t.orderId.equals(orderId)))
        .go();
  }

  /// Get order products (standalone products) for a given order
  Future<List<OrderProduct>> getOrderProducts(int orderId) {
    return (select(orderProducts)..where((t) => t.orderId.equals(orderId)))
        .get();
  }

  /// Add an order product entry
  Future<int> addOrderProduct(OrderProductsCompanion product) {
    return into(orderProducts).insert(product);
  }

  /// Delete all order products for a given order
  Future<int> deleteOrderProductsByOrderId(int orderId) {
    return (delete(orderProducts)..where((t) => t.orderId.equals(orderId))).go();
  }

  /// Get order items
  Future<List<OrderItem>> getOrderItems(int orderId) {
    return (select(orderItems)..where((t) => t.orderId.equals(orderId)))
        .get();
  }

  /// Add order item
  Future<int> addOrderItem(OrderItemsCompanion item) {
    return into(orderItems).insert(item);
  }

  /// Get order materials
  Future<List<OrderMaterial>> getOrderMaterials(int orderId) {
    return (select(orderMaterials)..where((t) => t.orderId.equals(orderId)))
        .get();
  }

  /// Add order material
  Future<int> addOrderMaterial(OrderMaterialsCompanion material) {
    return into(orderMaterials).insert(material);
  }

  /// Update order material
  Future<bool> updateOrderMaterial(OrderMaterial material) {
    return update(orderMaterials).replace(material);
  }

  /// The order's field values with their definitions, archived included,
  /// in field order.
  Future<List<(OrderFieldDefinition, String)>> getFieldValues(
      int orderId) async {
    final query = select(orderFieldValues).join([
      innerJoin(
        orderFieldDefinitions,
        orderFieldDefinitions.id.equalsExp(orderFieldValues.fieldId),
      ),
    ])
      ..where(orderFieldValues.orderId.equals(orderId))
      ..orderBy([
        OrderingTerm.asc(orderFieldDefinitions.position),
        OrderingTerm.asc(orderFieldDefinitions.id),
      ]);
    final rows = await query.get();
    return [
      for (final r in rows)
        (r.readTable(orderFieldDefinitions), r.readTable(orderFieldValues).value),
    ];
  }

  /// Replaces the order's values with [values] (field id → value). Ids whose
  /// field no longer exists are skipped: one may be deleted while the order
  /// form is still open.
  Future<void> replaceFieldValues(int orderId, Map<int, String> values) async {
    await deleteFieldValuesByOrderId(orderId);
    if (values.isEmpty) return;
    final existing = await (selectOnly(orderFieldDefinitions)
          ..addColumns([orderFieldDefinitions.id])
          ..where(orderFieldDefinitions.id.isIn(values.keys)))
        .map((r) => r.read(orderFieldDefinitions.id)!)
        .get();
    for (final id in existing) {
      await into(orderFieldValues).insert(OrderFieldValuesCompanion.insert(
        orderId: orderId,
        fieldId: id,
        value: values[id]!,
      ));
    }
  }

  Future<int> deleteFieldValuesByOrderId(int orderId) {
    return (delete(orderFieldValues)..where((t) => t.orderId.equals(orderId)))
        .go();
  }

  /// Look up product name by ID
  Future<String> getProductName(int productId) async {
    final row = await (select(products)..where((t) => t.id.equals(productId)))
        .getSingleOrNull();
    return row?.name ?? '';
  }

  /// Look up material name by ID
  Future<String> getMaterialName(int materialId) async {
    final row =
        await (select(materials)..where((t) => t.id.equals(materialId)))
            .getSingleOrNull();
    return row?.name ?? '';
  }
}
