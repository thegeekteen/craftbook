import 'dart:math';

import 'package:drift/drift.dart' hide Column;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/material_dao.dart';
import '../../../../database/daos/product_dao.dart';
import '../../domain/entities/buy_list_item.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/material_repository.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final MaterialDao dao;
  final ProductDao productDao;

  MaterialRepositoryImpl(this.dao, this.productDao);

  @override
  Future<Result<List<Material>>> getAllMaterials() async {
    try {
      final rows = await dao.getAllMaterials();
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Material?>> getMaterialById(int id) async {
    try {
      final row = await dao.getMaterialById(id);
      return Success(row != null ? _toEntity(row) : null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Material>>> getLowStockMaterials() async {
    try {
      final rows = await dao.getLowStockMaterials();
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<StockMovement>>> getStockMovements(
    int materialId,
  ) async {
    try {
      final rows = await dao.getStockMovements(materialId);
      return Success(rows.map(_toMovementEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> createMaterial({
    required String name,
    required int packSize,
    required double packPrice,
    required double unitCost,
    required int quantityOnHand,
    required int alertLevel,
    String? supplier,
  }) async {
    try {
      final id = await dao.createMaterial(db.MaterialsCompanion(
        name: Value(name),
        packSize: Value(packSize),
        packPrice: Value(packPrice),
        unitCost: Value(unitCost),
        quantityOnHand: Value(quantityOnHand),
        alertLevel: Value(alertLevel),
        supplier: Value(supplier),
      ));
      return Success(id);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> receiveStock({
    required int materialId,
    required int packsReceived,
    required double pricePerPack,
    DateTime? receivedAt,
    String? supplier,
  }) async {
    try {
      final current = await dao.getMaterialById(materialId);
      if (current == null) {
        return Error(NotFoundFailure('Material not found'));
      }

      final newQty = packsReceived * current.packSize;
      final oldQty = current.quantityOnHand;
      final newUnitPrice = pricePerPack / current.packSize;

      // Weighted average unit cost
      final totalQty = oldQty + newQty;
      final double newUnitCost;
      if (totalQty == 0) {
        newUnitCost = 0;
      } else {
        newUnitCost =
            (oldQty * current.unitCost + newQty * newUnitPrice) / totalQty;
      }

      final now = receivedAt ?? DateTime.now();

      // Update material with new quantities, cost, and metadata
      await dao.updateMaterial(db.Material(
        id: current.id,
        name: current.name,
        packSize: current.packSize,
        packPrice: pricePerPack,
        unitCost: newUnitCost,
        quantityOnHand: current.quantityOnHand + newQty,
        quantityPromised: current.quantityPromised,
        alertLevel: current.alertLevel,
        supplier: supplier ?? current.supplier,
        lastReceivedAt: now,
        createdAt: current.createdAt,
        updatedAt: now,
      ));

      // Record stock movement
      await dao.addStockMovement(db.StockMovementsCompanion(
        materialId: Value(materialId),
        type: Value('received'),
        quantity: Value(newQty),
        unitCost: Value(newUnitPrice),
        reference: Value('Received $packsReceived packs'),
      ));

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> adjustStock(
    int materialId,
    int newQuantityOnHand,
  ) async {
    try {
      final current = await dao.getMaterialById(materialId);
      if (current == null) {
        return Error(NotFoundFailure('Material not found'));
      }

      final difference = newQuantityOnHand - current.quantityOnHand;

      await dao.updateMaterialStock(materialId, newQuantityOnHand, current.quantityPromised);

      // Record stock movement
      await dao.addStockMovement(db.StockMovementsCompanion(
        materialId: Value(materialId),
        type: Value('adjusted'),
        quantity: Value(difference),
        unitCost: Value(current.unitCost),
        reference: Value('Adjusted from ${current.quantityOnHand} to $newQuantityOnHand'),
      ));

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> reserveMaterials(
    int materialId,
    int quantity,
  ) async {
    try {
      final current = await dao.getMaterialById(materialId);
      if (current == null) {
        return Error(NotFoundFailure('Material not found'));
      }

      await dao.updateMaterialStock(
        materialId,
        current.quantityOnHand,
        current.quantityPromised + quantity,
      );

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> releaseReservedMaterials(
    int materialId,
    int quantity,
  ) async {
    try {
      final current = await dao.getMaterialById(materialId);
      if (current == null) {
        return Error(NotFoundFailure('Material not found'));
      }

      await dao.updateMaterialStock(
        materialId,
        current.quantityOnHand,
        max(0, current.quantityPromised - quantity),
      );

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deductMaterials(
    int materialId,
    int quantity, {
    int? reserved,
  }) async {
    try {
      final current = await dao.getMaterialById(materialId);
      if (current == null) {
        return Error(NotFoundFailure('Material not found'));
      }

      await dao.updateMaterialStock(
        materialId,
        max(0, current.quantityOnHand - quantity),
        max(0, current.quantityPromised - (reserved ?? quantity)),
      );

      // Record stock movement
      await dao.addStockMovement(db.StockMovementsCompanion(
        materialId: Value(materialId),
        type: Value('deducted'),
        quantity: Value(quantity),
        unitCost: Value(current.unitCost),
        reference: Value('Deducted for order'),
      ));

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> restoreDeductedMaterials(
    int materialId,
    int quantity,
  ) async {
    try {
      final current = await dao.getMaterialById(materialId);
      if (current == null) {
        return Error(NotFoundFailure('Material not found'));
      }

      await dao.updateMaterialStock(
        materialId,
        current.quantityOnHand + quantity,
        current.quantityPromised,
      );

      await dao.addStockMovement(db.StockMovementsCompanion(
        materialId: Value(materialId),
        type: Value('received'),
        quantity: Value(quantity),
        unitCost: Value(current.unitCost),
        reference: Value('Restored from deleted order'),
      ));

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<BuyListItem>>> getBuyList() async {
    try {
      final lowStockMaterials = await dao.getLowStockMaterials();
      final allProducts = await productDao.getActiveProducts();
      final buyList = <BuyListItem>[];

      for (final material in lowStockMaterials) {
        // Calculate packs needed to reach alert level + cover promised
        final targetQty = material.alertLevel + material.quantityPromised;
        final deficit = targetQty - material.quantityOnHand;
        final packSize = material.packSize > 0 ? material.packSize : 1;
        // Anything on this list needs at least one pack, even when it sits
        // exactly at its reorder level.
        final packsToOrder =
            deficit > 0 ? (deficit / packSize).ceil() : 1;

        // Find products blocked by this material
        final blockedProducts = <BlockedProduct>[];
        for (final product in allProducts) {
          final bomItems = await productDao.getBomItems(product.id);
          final usesMaterial =
              bomItems.any((bom) => bom.materialId == material.id);
          if (!usesMaterial) continue;

          final buildable =
              await productDao.calculateBuildableQuantity(product.id);

          // Count open orders for this product
          final openOrderCount = await _countOpenOrdersForProduct(product.id);

          blockedProducts.add(BlockedProduct(
            productId: product.id,
            productName: product.name,
            buildableQuantity: buildable,
            openOrderCount: openOrderCount,
          ));
        }

        buyList.add(BuyListItem(
          materialId: material.id,
          materialName: material.name,
          quantityOnHand: material.quantityOnHand,
          quantityPromised: material.quantityPromised,
          alertLevel: material.alertLevel,
          packSize: material.packSize,
          packPrice: material.packPrice,
          packsToOrder: packsToOrder,
          blockedProducts: blockedProducts,
        ));
      }

      return Success(buyList);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteMaterial(int id) async {
    try {
      await dao.deleteMaterial(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  /// Count open (non-shipped) orders that contain a given product.
  Future<int> _countOpenOrdersForProduct(int productId) async {
    // Use a custom query through the database to join order_items with orders
    final result = await dao.customSelect(
      '''
      SELECT COUNT(DISTINCT oi.order_id) as cnt
      FROM order_items oi
      INNER JOIN orders o ON o.id = oi.order_id
      WHERE oi.product_id = ? AND o.status IN ('pending', 'confirmed', 'packed')
      ''',
      variables: [Variable.withInt(productId)],
    ).getSingleOrNull();

    return result?.read<int>('cnt') ?? 0;
  }

  // ── Mapping helpers ───────────────────────────────────────────────────

  static Material _toEntity(db.Material row) => Material(
        id: row.id,
        name: row.name,
        packSize: row.packSize,
        packPrice: row.packPrice,
        unitCost: row.unitCost,
        quantityOnHand: row.quantityOnHand,
        quantityPromised: row.quantityPromised,
        alertLevel: row.alertLevel,
        supplier: row.supplier,
        lastReceivedAt: row.lastReceivedAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  static StockMovement _toMovementEntity(db.StockMovement row) {
    return StockMovement(
      id: row.id,
      materialId: row.materialId,
      orderId: row.orderId,
      type: _parseMovementType(row.type),
      quantity: row.quantity,
      unitCost: row.unitCost,
      createdAt: row.createdAt,
      reference: row.reference,
    );
  }

  static StockMovementType _parseMovementType(String type) {
    switch (type) {
      case 'received':
        return StockMovementType.received;
      case 'deducted':
        return StockMovementType.deducted;
      case 'adjusted':
        return StockMovementType.adjusted;
      case 'waste':
        return StockMovementType.waste;
      default:
        return StockMovementType.adjusted;
    }
  }
}
