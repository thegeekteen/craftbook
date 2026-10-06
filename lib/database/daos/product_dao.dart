import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/products_table.dart';
import '../tables/bom_items_table.dart';
import '../tables/materials_table.dart';
import '../tables/product_stock_movements_table.dart';
import '../tables/order_products_table.dart';
import '../tables/orders_table.dart';
import '../tables/order_items_table.dart';

part 'product_dao.g.dart';

/// Data Access Object for products
@DriftAccessor(tables: [
  Products,
  BomItems,
  Materials,
  ProductStockMovements,
  OrderProducts,
  Orders,
  OrderItems
])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  /// Get all products
  Future<List<Product>> getAllProducts() {
    return select(products).get();
  }

  /// Get active products
  Future<List<Product>> getUnarchivedProducts() {
    return (select(products)..where((t) => t.isArchived.equals(false))).get();
  }

  /// Get product by ID
  Future<Product?> getProductById(int id) {
    return (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Create new product
  Future<int> createProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }

  /// Update product
  Future<bool> updateProduct(Product product) {
    return update(products).replace(product);
  }

  /// Delete product
  Future<int> deleteProduct(int id) {
    return (delete(products)..where((t) => t.id.equals(id))).go();
  }

  /// Get BOM items for product
  Future<List<BomItem>> getBomItems(int productId) {
    return (select(bomItems)..where((t) => t.productId.equals(productId)))
        .get();
  }

  /// Add BOM item
  Future<int> addBomItem(BomItemsCompanion bomItem) {
    return into(bomItems).insert(bomItem);
  }

  /// Update BOM item
  Future<bool> updateBomItem(BomItem bomItem) {
    return update(bomItems).replace(bomItem);
  }

  /// Delete BOM item
  Future<int> deleteBomItem(int id) {
    return (delete(bomItems)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all BOM items for a given product
  Future<int> deleteBomItemsByProductId(int productId) {
    return (delete(bomItems)..where((t) => t.productId.equals(productId))).go();
  }

  /// Check if any order_items reference this product
  Future<bool> hasOrderItemsForProduct(int productId) async {
    final result = await customSelect(
      'SELECT COUNT(*) as cnt FROM order_items WHERE product_id = ?',
      variables: [Variable.withInt(productId)],
      readsFrom: {bomItems},
    ).getSingle();
    return result.read<int>('cnt') > 0;
  }

  /// Calculate buildable quantity for product.
  /// For standalone products, returns quantityFree (on hand - promised).
  /// For BOM products, returns min(material available / required) across all
  /// BOM items, unrounded: callers floor it for display, but the raw value is
  /// what the low and short checks compare against the alert level.
  Future<double> calculateBuildableQuantity(int productId) async {
    final product = await getProductById(productId);
    if (product == null) return 0;

    if (product.isStandalone) {
      return product.quantityOnHand - product.quantityPromised;
    }

    final bomItems = await getBomItems(productId);
    if (bomItems.isEmpty) return 0;

    double? minBuildable;

    for (final bomItem in bomItems) {
      final material = await getMaterialById(bomItem.materialId);
      if (material == null) return 0;

      final available = material.quantityOnHand - material.quantityPromised;
      // One piece can make several products (a sheet makes 9 cards).
      final buildable = available * bomItem.makes / bomItem.quantityRequired;

      if (minBuildable == null || buildable < minBuildable) {
        minBuildable = buildable;
      }
    }

    return minBuildable ?? 0;
  }

  /// How many pending orders each product appears in, by product id.
  ///
  /// Only pending orders still hold reservations; packed ones have already
  /// taken their stock.
  Future<Map<int, int>> pendingOrderCounts() async {
    final rows = await customSelect(
      '''
      SELECT oi.product_id AS product_id, COUNT(DISTINCT oi.order_id) AS cnt
      FROM order_items oi
      INNER JOIN orders o ON o.id = oi.order_id
      WHERE o.status = 'pending'
      GROUP BY oi.product_id
      ''',
      readsFrom: {orderItems, orders},
    ).get();
    return {
      for (final r in rows) r.read<int>('product_id'): r.read<int>('cnt'),
    };
  }

  /// Get material by ID (helper)
  Future<Material?> getMaterialById(int id) {
    return (select(materials)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Active standalone products at or below their alert level.
  Future<List<Product>> getLowStockProducts() {
    return (select(products)
          ..where((t) =>
              t.isStandalone.equals(true) &
              t.isArchived.equals(false) &
              t.quantityOnHand.isSmallerOrEqual(t.alertLevel) &
              t.alertLevel.isBiggerThanValue(0)))
        .get();
  }

  /// Update product stock quantities
  Future<int> updateProductStock(
      int id, double quantityOnHand, double quantityPromised) {
    return (update(products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(
        quantityOnHand: Value(quantityOnHand),
        quantityPromised: Value(quantityPromised),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Sets or clears (null) the product photo without touching other columns.
  Future<int> setProductPhoto(int id, Uint8List? photo) {
    return (update(products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(
        photo: Value(photo),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get stock movements for a product
  Future<List<ProductStockMovement>> getProductStockMovements(int productId) {
    return (select(productStockMovements)
          ..where((t) => t.productId.equals(productId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Every order line for [productId] with its order, any status, newest
  /// order first.
  Future<List<(OrderItem, Order)>> getOrderLinesForProduct(
      int productId) async {
    final query = select(orderItems).join([
      innerJoin(orders, orders.id.equalsExp(orderItems.orderId)),
    ])
      ..where(orderItems.productId.equals(productId))
      ..orderBy(
          [OrderingTerm.desc(orders.orderDate), OrderingTerm.desc(orders.id)]);
    final rows = await query.get();
    return [
      for (final r in rows) (r.readTable(orderItems), r.readTable(orders))
    ];
  }

  /// Add a product stock movement
  Future<int> addProductStockMovement(ProductStockMovementsCompanion movement) {
    return into(productStockMovements).insert(movement);
  }

  /// Check if any product stock movements exist
  Future<bool> hasProductStockMovements(int productId) async {
    final result = await customSelect(
      'SELECT COUNT(*) as cnt FROM product_stock_movements WHERE product_id = ?',
      variables: [Variable.withInt(productId)],
      readsFrom: {productStockMovements},
    ).getSingle();
    return result.read<int>('cnt') > 0;
  }

  /// Get order products for a given order
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
    return (delete(orderProducts)..where((t) => t.orderId.equals(orderId)))
        .go();
  }

  /// Delete a product's whole stock history
  Future<int> deleteProductStockMovementsForProduct(int productId) {
    return (delete(productStockMovements)
          ..where((t) => t.productId.equals(productId)))
        .go();
  }

  /// Delete product stock movements referencing a given order
  Future<int> deleteProductStockMovementsByOrderId(int orderId) {
    return (delete(productStockMovements)
          ..where((t) => t.orderId.equals(orderId)))
        .go();
  }
}
