import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/materials_table.dart';
import '../tables/order_materials_table.dart';
import '../tables/stock_movements_table.dart';

part 'material_dao.g.dart';

/// Data Access Object for materials
@DriftAccessor(tables: [Materials, StockMovements, OrderMaterials])
class MaterialDao extends DatabaseAccessor<AppDatabase>
    with _$MaterialDaoMixin {
  MaterialDao(super.db);

  /// Get all materials
  Future<List<Material>> getAllMaterials() {
    return select(materials).get();
  }

  /// Get material by ID
  Future<Material?> getMaterialById(int id) {
    return (select(materials)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Unarchived materials at or below their alert level
  Future<List<Material>> getLowStockMaterials() {
    return (select(materials)
          // Same rule as Material.isLowStock: at or below the reorder level.
          ..where((t) =>
              t.isArchived.equals(false) &
              t.quantityOnHand.isSmallerOrEqual(t.alertLevel)))
        .get();
  }

  /// Archive or unarchive a material
  Future<int> setMaterialArchived(int id, bool archived) {
    return (update(materials)..where((t) => t.id.equals(id))).write(
        MaterialsCompanion(
            isArchived: Value(archived), updatedAt: Value(DateTime.now())));
  }

  /// Create new material
  Future<int> createMaterial(MaterialsCompanion material) {
    return into(materials).insert(material);
  }

  /// Update material
  Future<bool> updateMaterial(Material material) {
    return update(materials).replace(material);
  }

  /// Update material stock
  Future<int> updateMaterialStock(
      int materialId, double quantityOnHand, double quantityPromised) {
    return (update(materials)..where((t) => t.id.equals(materialId)))
        .write(MaterialsCompanion(
      quantityOnHand: Value(quantityOnHand),
      quantityPromised: Value(quantityPromised),
    ));
  }

  /// Delete material
  Future<int> deleteMaterial(int id) {
    return (delete(materials)..where((t) => t.id.equals(id))).go();
  }

  /// Whether any order, in any status, used this material.
  Future<bool> hasOrderMaterialsForMaterial(int materialId) async {
    final result = await customSelect(
      'SELECT COUNT(*) as cnt FROM order_materials WHERE material_id = ?',
      variables: [Variable.withInt(materialId)],
      readsFrom: {orderMaterials},
    ).getSingle();
    return result.read<int>('cnt') > 0;
  }

  /// Delete a material's whole stock history
  Future<int> deleteStockMovementsForMaterial(int materialId) {
    return (delete(stockMovements)
          ..where((t) => t.materialId.equals(materialId)))
        .go();
  }

  /// Get stock movements for material
  Future<List<StockMovement>> getStockMovements(int materialId) {
    return (select(stockMovements)
          ..where((t) => t.materialId.equals(materialId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Add stock movement
  Future<int> addStockMovement(StockMovementsCompanion movement) {
    return into(stockMovements).insert(movement);
  }

  /// Get materials used in product (via BOM)
  Future<List<Material>> getMaterialsForProduct(int productId) async {
    final rows = await customSelect(
      '''
      SELECT materials.* FROM materials
      INNER JOIN bom_items ON materials.id = bom_items.material_id
      WHERE bom_items.product_id = ?
      ''',
      variables: [Variable.withInt(productId)],
      readsFrom: {materials},
    ).get();

    return Future.wait(rows.map((row) => materials.mapFromRow(row)));
  }
}
