import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/materials_table.dart';
import '../tables/stock_movements_table.dart';

part 'material_dao.g.dart';

/// Data Access Object for materials
@DriftAccessor(tables: [Materials, StockMovements])
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

  /// Get materials below alert level
  Future<List<Material>> getLowStockMaterials() {
    return (select(materials)
          // Same rule as Material.isLowStock: at or below the reorder level.
          ..where((t) => t.quantityOnHand.isSmallerOrEqual(t.alertLevel)))
        .get();
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
      int materialId, int quantityOnHand, int quantityPromised) {
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
