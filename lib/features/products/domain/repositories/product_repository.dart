import 'dart:typed_data';

import 'package:craftbook/core/error/result.dart';

import '../entities/product.dart';
import '../entities/bom_item.dart';
import '../entities/product_sale.dart';
import '../entities/product_stock_movement.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getAllProducts();
  Future<Result<List<Product>>> getUnarchivedProducts();
  Future<Result<Product?>> getProductById(int id);
  Future<Result<List<BomItem>>> getBomItems(int productId);
  Future<Result<int>> createProduct({
    required String name,
    String? description,
    required double sellPrice,

    /// What it's sold and counted in. Null uses the shop's default unit.
    int? unitId,
    bool isStandalone,
    double initialQuantity,
    double initialUnitCost,
  });

  /// Null leaves a field as is. An empty [description] clears it. [unitCost]
  /// only matters for resell products (handmade cost comes from the BOM).
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
  });

  /// Sets the product photo, or clears it when [photo] is null.
  Future<Result<void>> setProductPhoto(int id, Uint8List? photo);
  Future<Result<void>> saveBomItems(int productId, List<BomItemInput> items);

  /// Unrounded: how much the materials on hand can build, or a resell
  /// product's free stock. Callers floor it for display.
  Future<Result<double>> calculateBuildableQuantity(int productId);
  Future<Result<double>> calculateBomCost(int productId);
  Future<Result<List<Product>>> getProductsUsingMaterial(int materialId);
  Future<Result<bool>> hasOrdersUsingProduct(int productId);
  Future<Result<void>> deleteProduct(int id);

  // Standalone product stock operations
  Future<Result<void>> receiveProductStock({
    required int productId,
    required double quantity,
    required double pricePerUnit,
    String? reference,
  });
  Future<Result<void>> adjustProductStock({
    required int productId,
    required double newQuantityOnHand,
  });
  Future<Result<void>> reserveProductStock(int productId, double quantity);
  Future<Result<void>> releaseReservedProductStock(
      int productId, double quantity);
  Future<Result<void>> deductProductStock(int productId, double quantity);

  /// Puts [quantity] back on hand, logged under [reference] in the history.
  Future<Result<void>> restoreDeductedProductStock(
      int productId, double quantity,
      {String reference = 'Restored from deleted order'});
  Future<Result<List<ProductStockMovement>>> getProductStockMovements(
      int productId);

  /// Active resell products at or below their alert level.
  Future<Result<List<Product>>> getLowStockProducts();

  /// Pending orders per product id; products with none are absent.
  Future<Result<Map<int, int>>> getPendingOrderCounts();

  /// Every order line this product appears in, across all statuses.
  Future<Result<List<ProductSale>>> getProductSales(int productId);
}

class BomItemInput {
  final int materialId;
  final double quantityRequired;

  /// How many products [quantityRequired] pieces make.
  final double makes;

  const BomItemInput({
    required this.materialId,
    required this.quantityRequired,
    this.makes = 1,
  });
}
