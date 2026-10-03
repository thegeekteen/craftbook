import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/error/failures.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/product_dao.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDao dao;

  ProductRepositoryImpl(this.dao);

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      final rows = await dao.getAllProducts();
      return Right(rows.map(_toEntity).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getActiveProducts() async {
    try {
      final rows = await dao.getActiveProducts();
      return Right(rows.map(_toEntity).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductById(int id) async {
    try {
      final row = await dao.getProductById(id);
      return Right(row != null ? _toEntity(row) : null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BomItem>>> getBomItems(int productId) async {
    try {
      final rows = await dao.getBomItems(productId);
      final items = <BomItem>[];
      for (final row in rows) {
        final material = await dao.getMaterialById(row.materialId);
        items.add(_toBomItemEntity(row, material));
      }
      return Right(items);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createProduct({
    required String name,
    String? description,
    required double sellPrice,
  }) async {
    try {
      final id = await dao.createProduct(db.ProductsCompanion(
        name: Value(name),
        description: Value(description),
        sellPrice: Value(sellPrice),
      ));
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct({
    required int id,
    String? name,
    String? description,
    double? sellPrice,
    bool? isActive,
  }) async {
    try {
      final existing = await dao.getProductById(id);
      if (existing == null) {
        return Left(NotFoundFailure('Product not found'));
      }

      await dao.updateProduct(db.Product(
        id: existing.id,
        name: name ?? existing.name,
        description: description ?? existing.description,
        sellPrice: sellPrice ?? existing.sellPrice,
        isActive: isActive ?? existing.isActive,
        createdAt: existing.createdAt,
        updatedAt: existing.updatedAt,
      ));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveBomItems(
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

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> calculateBuildableQuantity(
    int productId,
  ) async {
    try {
      final quantity = await dao.calculateBuildableQuantity(productId);
      return Right(quantity);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> calculateBomCost(int productId) async {
    try {
      final bomRows = await dao.getBomItems(productId);
      double total = 0;
      for (final row in bomRows) {
        final material = await dao.getMaterialById(row.materialId);
        if (material != null) {
          total += row.quantityRequired * material.unitCost;
        }
      }
      return Right(total);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsUsingMaterial(
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

      return Right(matchingProducts);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasOrdersUsingProduct(int productId) async {
    try {
      final result = await dao.hasOrderItemsForProduct(productId);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    try {
      await dao.deleteBomItemsByProductId(id);
      await dao.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  // ── Mappers ────────────────────────────────────────────────────────

  static Product _toEntity(db.Product row) => Product(
        id: row.id,
        name: row.name,
        description: row.description,
        sellPrice: row.sellPrice,
        isActive: row.isActive,
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
}
