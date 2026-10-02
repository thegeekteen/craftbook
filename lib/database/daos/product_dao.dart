import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/products_table.dart';
import '../tables/bom_items_table.dart';
import '../tables/materials_table.dart';

part 'product_dao.g.dart';

/// Data Access Object for products
@DriftAccessor(tables: [Products, BomItems, Materials])
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

  /// Calculate buildable quantity for product
  Future<int> calculateBuildableQuantity(int productId) async {
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
}
