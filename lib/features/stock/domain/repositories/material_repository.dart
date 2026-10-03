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
    required int packSize,
    required double packPrice,
    required double unitCost,
    required int quantityOnHand,
    required int alertLevel,
    String? supplier,
  });
  Future<Result<void>> receiveStock({
    required int materialId,
    required int packsReceived,
    required double pricePerPack,
    DateTime? receivedAt,
    String? supplier,
  });
  Future<Result<void>> adjustStock(int materialId, int newQuantityOnHand);
  Future<Result<void>> reserveMaterials(int materialId, int quantity);
  Future<Result<void>> releaseReservedMaterials(int materialId, int quantity);
  Future<Result<void>> deductMaterials(int materialId, int quantity);
  Future<Result<void>> restoreDeductedMaterials(int materialId, int quantity);
  Future<Result<List<BuyListItem>>> getBuyList();
  Future<Result<void>> deleteMaterial(int id);
}
