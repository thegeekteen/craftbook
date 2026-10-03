import 'package:craftbook/core/error/result.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/error/failures.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/product_dao.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_stock_movement.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDao dao;

  ProductRepositoryImpl(this.dao);

  @override
  Future<Result<List<Product>>> getAllProducts() async {
    try {
      final rows = await dao.getAllProducts();
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getActiveProducts() async {
    try {
      final rows = await dao.getActiveProducts();
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product?>> getProductById(int id) async {
    try {
      final row = await dao.getProductById(id);
      return Success(row != null ? _toEntity(row) : null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<BomItem>>> getBomItems(int productId) async {
    try {
      final rows = await dao.getBomItems(productId);
      final items = <BomItem>[];
      for (final row in rows) {
        final material = await dao.getMaterialById(row.materialId);
        items.add(_toBomItemEntity(row, material));
      }
      return Success(items);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> createProduct({
    required String name,
    String? description,
    required double sellPrice,
    bool isStandalone = false,
    int initialQuantity = 0,
    double initialUnitCost = 0,
  }) async {
    try {
      final id = await dao.createProduct(db.ProductsCompanion(
        name: Value(name),
        description: Value(description),
        sellPrice: Value(sellPrice),
        isStandalone: Value(isStandalone),
        quantityOnHand: Value(isStandalone ? initialQuantity : 0),
        unitCost: Value(isStandalone ? initialUnitCost : 0.0),
      ));

      // Record initial stock movement if standalone with initial quantity
      if (isStandalone && initialQuantity > 0) {
        await dao.addProductStockMovement(
          db.ProductStockMovementsCompanion(
            productId: Value(id),
            type: const Value('received'),
            quantity: Value(initialQuantity),
            unitCost: Value(initialUnitCost),
            reference: const Value('Initial stock'),
          ),
        );
      }

      return Success(id);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateProduct({
    required int id,
    String? name,
    String? description,
    double? sellPrice,
    bool? isActive,
    bool? isStandalone,
    int? alertLevel,
  }) async {
    try {
      final existing = await dao.getProductById(id);
      if (existing == null) {
        return Error(NotFoundFailure('Product not found'));
      }

      await dao.updateProduct(db.Product(
        id: existing.id,
        name: name ?? existing.name,
        description: description ?? existing.description,
        sellPrice: sellPrice ?? existing.sellPrice,
        isActive: isActive ?? existing.isActive,
        isStandalone: isStandalone ?? existing.isStandalone,
        quantityOnHand: existing.quantityOnHand,
        quantityPromised: existing.quantityPromised,
        unitCost: existing.unitCost,
        alertLevel: alertLevel ?? existing.alertLevel,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      ));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveBomItems(
    int productId,
    List<BomItemInput> items,
  ) async {
    try {
      // Delete existing BOM items for this product
      final existing = await dao.getBomItems(productId);
      for (final item in existing) {
        await dao.deleteBomItem(item.id);
      }

      // Insert new BOM items
      for (final item in items) {
        await dao.addBomItem(db.BomItemsCompanion(
          productId: Value(productId),
          materialId: Value(item.materialId),
          quantityRequired: Value(item.quantityRequired),
        ));
      }

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> calculateBuildableQuantity(
    int productId,
  ) async {
    try {
      final quantity = await dao.calculateBuildableQuantity(productId);
      return Success(quantity);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<double>> calculateBomCost(int productId) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return Error(NotFoundFailure('Product not found'));
      }

      // Standalone products use their own unit cost
      if (product.isStandalone) {
        return Success(product.unitCost);
      }

      final bomRows = await dao.getBomItems(productId);
      double total = 0;
      for (final row in bomRows) {
        final material = await dao.getMaterialById(row.materialId);
        if (material != null) {
          total += row.quantityRequired * material.unitCost;
        }
      }
      return Success(total);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getProductsUsingMaterial(
    int materialId,
  ) async {
    try {
      final allProducts = await dao.getAllProducts();
      final matchingProducts = <Product>[];

      for (final product in allProducts) {
        final bomItems = await dao.getBomItems(product.id);
        if (bomItems.any((b) => b.materialId == materialId)) {
          matchingProducts.add(_toEntity(product));
        }
      }

      return Success(matchingProducts);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> hasOrdersUsingProduct(int productId) async {
    try {
      final result = await dao.hasOrderItemsForProduct(productId);
      return Success(result);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      await dao.deleteBomItemsByProductId(id);
      await dao.deleteProduct(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> receiveProductStock({
    required int productId,
    required int quantity,
    required double pricePerUnit,
    String? reference,
  }) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return Error(NotFoundFailure('Product not found'));
      }

      final oldQty = product.quantityOnHand;
      final oldCost = product.unitCost;
      final newQty = oldQty + quantity;
      final newUnitCost =
          newQty > 0 ? (oldQty * oldCost + quantity * pricePerUnit) / newQty : 0.0;

      await (dao.db.update(dao.db.products)
            ..where((t) => t.id.equals(productId)))
          .write(db.ProductsCompanion(
        quantityOnHand: Value(newQty),
        unitCost: Value(newUnitCost),
        updatedAt: Value(DateTime.now()),
      ));

      await dao.addProductStockMovement(
        db.ProductStockMovementsCompanion(
          productId: Value(productId),
          type: const Value('received'),
          quantity: Value(quantity),
          unitCost: Value(pricePerUnit),
          reference: Value(reference ?? 'Received $quantity units'),
        ),
      );

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> adjustProductStock({
    required int productId,
    required int newQuantityOnHand,
  }) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return Error(NotFoundFailure('Product not found'));
      }

      await dao.updateProductStock(
        productId,
        newQuantityOnHand,
        product.quantityPromised,
      );

      final diff = newQuantityOnHand - product.quantityOnHand;
      await dao.addProductStockMovement(
        db.ProductStockMovementsCompanion(
          productId: Value(productId),
          type: const Value('adjusted'),
          quantity: Value(diff.abs()),
          unitCost: Value(product.unitCost),
          reference: Value(diff >= 0
              ? 'Adjusted +$diff units'
              : 'Adjusted $diff units'),
        ),
      );

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> reserveProductStock(
    int productId,
    int quantity,
  ) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return Error(NotFoundFailure('Product not found'));
      }
      await dao.updateProductStock(
        productId,
        product.quantityOnHand,
        product.quantityPromised + quantity,
      );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> releaseReservedProductStock(
    int productId,
    int quantity,
  ) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return Error(NotFoundFailure('Product not found'));
      }
      final newPromised = (product.quantityPromised - quantity).clamp(0, 999999);
      await dao.updateProductStock(
        productId,
        product.quantityOnHand,
        newPromised,
      );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deductProductStock(
    int productId,
    int quantity,
  ) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return Error(NotFoundFailure('Product not found'));
      }
      final newOnHand = (product.quantityOnHand - quantity).clamp(0, 999999);
      final newPromised = (product.quantityPromised - quantity).clamp(0, 999999);
      await dao.updateProductStock(productId, newOnHand, newPromised);

      await dao.addProductStockMovement(
        db.ProductStockMovementsCompanion(
          productId: Value(productId),
          type: const Value('deducted'),
          quantity: Value(quantity),
          unitCost: Value(product.unitCost),
          reference: const Value('Deducted for order'),
        ),
      );

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> restoreDeductedProductStock(
    int productId,
    int quantity,
  ) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return Error(NotFoundFailure('Product not found'));
      }
      await dao.updateProductStock(
        productId,
        product.quantityOnHand + quantity,
        product.quantityPromised,
      );

      await dao.addProductStockMovement(
        db.ProductStockMovementsCompanion(
          productId: Value(productId),
          type: const Value('received'),
          quantity: Value(quantity),
          unitCost: Value(product.unitCost),
          reference: const Value('Restored from deleted order'),
        ),
      );

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ProductStockMovement>>> getProductStockMovements(
    int productId,
  ) async {
    try {
      final rows = await dao.getProductStockMovements(productId);
      return Success(rows.map(_toStockMovementEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      final rows = await dao.getLowStockProducts();
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  // ── Mappers ────────────────────────────────────────────────────────

  static Product _toEntity(db.Product row) => Product(
        id: row.id,
        name: row.name,
        description: row.description,
        sellPrice: row.sellPrice,
        isActive: row.isActive,
        isStandalone: row.isStandalone,
        quantityOnHand: row.quantityOnHand,
        quantityPromised: row.quantityPromised,
        unitCost: row.unitCost,
        alertLevel: row.alertLevel,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  static BomItem _toBomItemEntity(
    db.BomItem row,
    db.Material? material,
  ) =>
      BomItem(
        id: row.id,
        productId: row.productId,
        materialId: row.materialId,
        materialName: material?.name ?? '',
        materialUnitCost: material?.unitCost ?? 0,
        quantityRequired: row.quantityRequired,
        createdAt: row.createdAt,
      );

  static ProductStockMovement _toStockMovementEntity(
    db.ProductStockMovement row,
  ) =>
      ProductStockMovement(
        id: row.id,
        productId: row.productId,
        orderId: row.orderId,
        type: ProductStockMovementType.values.firstWhere(
          (e) => e.name == row.type,
          orElse: () => ProductStockMovementType.received,
        ),
        quantity: row.quantity,
        unitCost: row.unitCost,
        createdAt: row.createdAt,
        reference: row.reference,
      );
}
