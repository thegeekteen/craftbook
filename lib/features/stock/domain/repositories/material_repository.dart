import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/material.dart';
import '../entities/stock_movement.dart';
import '../entities/buy_list_item.dart';

abstract class MaterialRepository {
  Future<Either<Failure, List<Material>>> getAllMaterials();
  Future<Either<Failure, Material?>> getMaterialById(int id);
  Future<Either<Failure, List<Material>>> getLowStockMaterials();
  Future<Either<Failure, List<StockMovement>>> getStockMovements(int materialId);
  Future<Either<Failure, int>> createMaterial({
    required String name,
    required int packSize,
    required double packPrice,
    required double unitCost,
    required int quantityOnHand,
    required int alertLevel,
    String? supplier,
  });
  Future<Either<Failure, void>> receiveStock({
    required int materialId,
    required int packsReceived,
    required double pricePerPack,
    DateTime? receivedAt,
    String? supplier,
  });
  Future<Either<Failure, void>> adjustStock(int materialId, int newQuantityOnHand);
  Future<Either<Failure, void>> reserveMaterials(int materialId, int quantity);
  Future<Either<Failure, void>> releaseReservedMaterials(int materialId, int quantity);
  Future<Either<Failure, void>> deductMaterials(int materialId, int quantity);
  Future<Either<Failure, List<BuyListItem>>> getBuyList();
  Future<Either<Failure, void>> deleteMaterial(int id);
}
