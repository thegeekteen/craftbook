import 'dart:math' as math;

import 'package:craftbook/core/error/result.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/product_dao.dart';
import '../../../../database/unit_lookup.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_sale.dart';
import '../../domain/entities/product_stock_movement.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDao dao;

  ProductRepositoryImpl(this.dao);

  @override
  Future<Result<List<Product>>> getAllProducts() async {
    try {
      final rows = await dao.getAllProducts();
      final units = await dao.db.unitLabels();
      return Success([for (final row in rows) _toEntity(row, units)]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getUnarchivedProducts() async {
    try {
      final rows = await dao.getUnarchivedProducts();
      final units = await dao.db.unitLabels();
      return Success([for (final row in rows) _toEntity(row, units)]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product?>> getProductById(int id) async {
    try {
      final row = await dao.getProductById(id);
      if (row == null) return const Success(null);
      return Success(_toEntity(row, await dao.db.unitLabels()));
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<BomItem>>> getBomItems(int productId) async {
    try {
      final rows = await dao.getBomItems(productId);
      final units = await dao.db.unitLabels();
      final items = <BomItem>[];
      for (final row in rows) {
        final material = await dao.getMaterialById(row.materialId);
        items.add(_toBomItemEntity(row, material, units));
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
    int? unitId,
    bool isStandalone = false,
    double initialQuantity = 0,
    double initialUnitCost = 0,
  }) async {
    try {
      final id = await dao.createProduct(db.ProductsCompanion(
        name: Value(name),
        description: Value(description),
        sellPrice: Value(sellPrice),
        unitId: Value(await _unitId(unitId)),
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
  Future<Result<void>> setProductPhoto(int id, Uint8List? photo) async {
    try {
      final updated = await dao.setProductPhoto(id, photo);
      if (updated == 0) {
        return const Error(NotFoundFailure('Product not found'));
      }
      return const Success(null);
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
    double? unitCost,
    int? unitId,
    bool? isArchived,
    bool? isStandalone,
    double? alertLevel,
  }) async {
    try {
      final existing = await dao.getProductById(id);
      if (existing == null) {
        return const Error(NotFoundFailure('Product not found'));
      }

      await dao.updateProduct(db.Product(
        id: existing.id,
        name: name ?? existing.name,
        description: description == null
            ? existing.description
            : (description.trim().isEmpty ? null : description.trim()),
        sellPrice: sellPrice ?? existing.sellPrice,
        unitId: await _unitId(unitId ?? existing.unitId),
        isArchived: isArchived ?? existing.isArchived,
        isStandalone: isStandalone ?? existing.isStandalone,
        quantityOnHand: existing.quantityOnHand,
        quantityPromised: existing.quantityPromised,
        unitCost: unitCost ?? existing.unitCost,
        alertLevel: alertLevel ?? existing.alertLevel,
        photo: existing.photo,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      ));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  /// Falls back to the shop's default unit, which is what a new product
  /// starts on until the form says otherwise.
  Future<int> _unitId(int? unitId) async =>
      unitId ?? await dao.db.defaultUnitId() ?? AppConstants.defaultUnitId;

  /// A unit's label, for the stock history text ("Received 5 pc").
  Future<String> _unitLabel(int unitId) async =>
      (await dao.db.unitLabels())[unitId] ?? '';

  @override
  Future<Result<void>> saveBomItems(
    int productId,
    List<BomItemInput> items,
  ) async {
    try {
      // One transaction so a failed insert can't leave the BOM half-replaced.
      await dao.transaction(() async {
        final existing = await dao.getBomItems(productId);
        for (final item in existing) {
          await dao.deleteBomItem(item.id);
        }
        for (final item in items) {
          await dao.addBomItem(db.BomItemsCompanion(
            productId: Value(productId),
            materialId: Value(item.materialId),
            quantityRequired: Value(item.quantityRequired),
            makes: Value(item.makes),
          ));
        }
      });

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<double>> calculateBuildableQuantity(
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
        return const Error(NotFoundFailure('Product not found'));
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
          total += row.quantityRequired * material.unitCost / row.makes;
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
      final units = await dao.db.unitLabels();
      final matchingProducts = <Product>[];

      for (final product in allProducts) {
        final bomItems = await dao.getBomItems(product.id);
        final usesMaterial = bomItems.any((b) => b.materialId == materialId);
        if (!usesMaterial) continue;
        matchingProducts.add(_toEntity(product, units));
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
      await dao.transaction(() async {
        await dao.deleteBomItemsByProductId(id);
        await dao.deleteProductStockMovementsForProduct(id);
        await dao.deleteProduct(id);
      });
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> receiveProductStock({
    required int productId,
    required double quantity,
    required double pricePerUnit,
    String? reference,
  }) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return const Error(NotFoundFailure('Product not found'));
      }

      final oldQty = product.quantityOnHand;
      final oldCost = product.unitCost;
      final newQty = qty(oldQty + quantity);
      final newUnitCost = newQty > 0
          ? (oldQty * oldCost + quantity * pricePerUnit) / newQty
          : 0.0;
      final unit = await _unitLabel(product.unitId);

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
          reference: Value(reference ??
              'Received ${QuantityFormatter.withUnit(quantity, unit)}'),
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
    required double newQuantityOnHand,
  }) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return const Error(NotFoundFailure('Product not found'));
      }

      await dao.updateProductStock(
        productId,
        newQuantityOnHand,
        product.quantityPromised,
      );

      final diff = qty(newQuantityOnHand - product.quantityOnHand);
      final unit = await _unitLabel(product.unitId);
      await dao.addProductStockMovement(
        db.ProductStockMovementsCompanion(
          productId: Value(productId),
          type: const Value('adjusted'),
          quantity: Value(diff),
          unitCost: Value(product.unitCost),
          reference: Value(diff >= 0
              ? 'Adjusted +${QuantityFormatter.format(diff)} $unit'
              : 'Adjusted ${QuantityFormatter.format(diff)} $unit'),
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
    double quantity,
  ) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return const Error(NotFoundFailure('Product not found'));
      }
      await dao.updateProductStock(
        productId,
        product.quantityOnHand,
        qty(product.quantityPromised + quantity),
      );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> releaseReservedProductStock(
    int productId,
    double quantity,
  ) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return const Error(NotFoundFailure('Product not found'));
      }
      final newPromised = math.max(0, product.quantityPromised - quantity);
      await dao.updateProductStock(
        productId,
        product.quantityOnHand,
        qty(newPromised),
      );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deductProductStock(
    int productId,
    double quantity,
  ) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return const Error(NotFoundFailure('Product not found'));
      }
      final newOnHand = math.max(0, product.quantityOnHand - quantity);
      final newPromised = math.max(0, product.quantityPromised - quantity);
      await dao.updateProductStock(productId, qty(newOnHand), qty(newPromised));

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
    double quantity, {
    String reference = 'Restored from deleted order',
  }) async {
    try {
      final product = await dao.getProductById(productId);
      if (product == null) {
        return const Error(NotFoundFailure('Product not found'));
      }
      await dao.updateProductStock(
        productId,
        qty(product.quantityOnHand + quantity),
        product.quantityPromised,
      );

      await dao.addProductStockMovement(
        db.ProductStockMovementsCompanion(
          productId: Value(productId),
          type: const Value('received'),
          quantity: Value(quantity),
          unitCost: Value(product.unitCost),
          reference: Value(reference),
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
  Future<Result<List<ProductSale>>> getProductSales(int productId) async {
    try {
      final rows = await dao.getOrderLinesForProduct(productId);
      return Success([
        for (final (item, order) in rows)
          ProductSale(
            orderId: order.id,
            customerName: order.customerName,
            status: _orderStatus(order.status),
            date: switch (order.status) {
              'shipped' => order.shippedAt ?? order.orderDate,
              'packed' => order.packedAt ?? order.orderDate,
              _ => order.orderDate,
            },
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            subtotal: item.subtotal,
          ),
      ]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      final rows = await dao.getLowStockProducts();
      final units = await dao.db.unitLabels();
      return Success([for (final row in rows) _toEntity(row, units)]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<int, int>>> getPendingOrderCounts() async {
    try {
      return Success(await dao.pendingOrderCounts());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  // ── Mappers ────────────────────────────────────────────────────────

  static Product _toEntity(db.Product row, Map<int, String> units) => Product(
        id: row.id,
        name: row.name,
        description: row.description,
        sellPrice: row.sellPrice,
        unitId: row.unitId,
        unit: units[row.unitId] ?? '',
        isArchived: row.isArchived,
        isStandalone: row.isStandalone,
        quantityOnHand: row.quantityOnHand,
        quantityPromised: row.quantityPromised,
        unitCost: row.unitCost,
        alertLevel: row.alertLevel,
        photo: row.photo,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  static BomItem _toBomItemEntity(
    db.BomItem row,
    db.Material? material,
    Map<int, String> units,
  ) =>
      BomItem(
        id: row.id,
        productId: row.productId,
        materialId: row.materialId,
        materialName: material?.name ?? '',
        materialUnit: material == null ? '' : units[material.unitId] ?? '',
        materialUnitCost: material?.unitCost ?? 0,
        quantityRequired: row.quantityRequired,
        makes: row.makes,
        createdAt: row.createdAt,
      );

  static OrderStatus _orderStatus(String status) =>
      OrderStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => OrderStatus.pending,
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
