import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/products_table.dart';
import '../tables/bom_items_table.dart';
import '../tables/materials_table.dart';
import '../tables/product_stock_movements_table.dart';
import '../tables/order_products_table.dart';

part 'product_dao.g.dart';

/// Data Access Object for products
@DriftAccessor(tables: [Products, BomItems, Materials, ProductStockMovements, OrderProducts])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(AppDatabase db) : super(db);

  /// Get all products
  Future<List<Product>> getAllProducts() {
    return select(products).get();
  }

  /// Get active products
  Future<List<Product>> getActiveProducts() {
    return (select(products)..where((t) => t.isActive.equals(true))).get();
  }

  /// Get product by ID
  Future<Product?> getProductById(int id) {
    return (select(products)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
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
  /// For BOM products, returns min(material available / required) across all BOM items.
  Future<int> calculateBuildableQuantity(int productId) async {
    final product = await getProductById(productId);
    if (product == null) return 0;

    if (product.isStandalone) {
      return product.quantityOnHand - product.quantityPromised;
    }

    final bomItems = await getBomItems(productId);
    if (bomItems.isEmpty) return 0;

    int minBuildable = double.maxFinite.toInt();

    for (final bomItem in bomItems) {
      final material = await getMaterialById(bomItem.materialId);
      if (material == null) return 0;

      final available = material.quantityOnHand - material.quantityPromised;
      final buildable = available ~/ bomItem.quantityRequired;

      if (buildable < minBuildable) {
        minBuildable = buildable;
      }
    }

    return minBuildable == double.maxFinite.toInt() ? 0 : minBuildable;
  }

  /// Get material by ID (helper)
  Future<Material?> getMaterialById(int id) {
    return (select(materials)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get low-stock standalone products
  Future<List<Product>> getLowStockProducts() {
    return (select(products)
          ..where((t) =>
              t.isStandalone.equals(true) &
              t.quantityOnHand.isSmallerOrEqual(t.alertLevel) &
              t.alertLevel.isBiggerThanValue(0)))
        .get();
  }

  /// Update product stock quantities
  Future<int> updateProductStock(int id, int quantityOnHand, int quantityPromised) {
    return (update(products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(
        quantityOnHand: Value(quantityOnHand),
        quantityPromised: Value(quantityPromised),
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
    return (delete(orderProducts)..where((t) => t.orderId.equals(orderId))).go();
  }

  /// Delete product stock movements referencing a given order
  Future<int> deleteProductStockMovementsByOrderId(int orderId) {
    return (delete(productStockMovements)
          ..where((t) => t.orderId.equals(orderId)))
        .go();
  }
}
