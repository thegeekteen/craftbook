import '../../../../core/error/result.dart';
import '../entities/material.dart';
import '../entities/stock_movement.dart';
import '../entities/buy_list_item.dart';

abstract class MaterialRepository {
  Future<Result<List<Material>>> getAllMaterials();
  Future<Result<Material?>> getMaterialById(int id);
  Future<Result<List<Material>>> getLowStockMaterials();
  Future<Result<List<StockMovement>>> getStockMovements(int materialId);
  Future<Result<int>> createMaterial({
    required String name,

    /// What it's counted in. Null uses the shop's default unit.
    int? unitId,
    required double packSize,
    required double packPrice,
    required double unitCost,
    required double quantityOnHand,
    required double alertLevel,
    String? supplier,
  });

  /// Edits the master data. Stock counts are never touched. [unitCost]
  /// (the weighted average) is only reset to packPrice / packSize when the
  /// price or pack size actually changed.
  Future<Result<void>> updateMaterial({
    required int id,
    required String name,
    int? unitId,
    required double packSize,
    required double packPrice,
    required double alertLevel,
    String? supplier,
  });
  Future<Result<void>> receiveStock({
    required int materialId,
    required int packsReceived,
    required double pricePerPack,
    DateTime? receivedAt,
    String? supplier,
  });
  Future<Result<void>> adjustStock(int materialId, double newQuantityOnHand);
  Future<Result<void>> setMaterialArchived(int materialId, bool archived);
  Future<Result<void>> reserveMaterials(int materialId, double quantity);
  Future<Result<void>> releaseReservedMaterials(
      int materialId, double quantity);

  /// Takes [quantity] off the shelf. [reserved] is how much of it this
  /// order had promised (defaults to [quantity]); only that much is
  /// released from promised, so other orders keep their reservations when
  /// more was used than planned.
  Future<Result<void>> deductMaterials(int materialId, double quantity,
      {double? reserved});

  /// Puts [quantity] back on hand, logged under [reference] in the history.
  Future<Result<void>> restoreDeductedMaterials(int materialId, double quantity,
      {String reference = 'Restored from deleted order'});
  Future<Result<List<BuyListItem>>> getBuyList();

  /// Whether any order, cancelled ones included, used this material.
  Future<Result<bool>> isUsedInOrders(int materialId);

  /// Removes the material together with its stock history.
  Future<Result<void>> deleteMaterial(int id);
}
