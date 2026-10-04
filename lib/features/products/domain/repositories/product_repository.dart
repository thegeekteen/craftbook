import 'package:craftbook/core/error/result.dart';

import '../entities/product.dart';
import '../entities/bom_item.dart';
import '../entities/product_sale.dart';
import '../entities/product_stock_movement.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getAllProducts();
  Future<Result<List<Product>>> getActiveProducts();
  Future<Result<Product?>> getProductById(int id);
  Future<Result<List<BomItem>>> getBomItems(int productId);
  Future<Result<int>> createProduct({
    required String name,
    String? description,
    required double sellPrice,
    bool isStandalone,
    int initialQuantity,
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
    bool? isActive,
    bool? isStandalone,
    int? alertLevel,
  });
  Future<Result<void>> saveBomItems(int productId, List<BomItemInput> items);
  Future<Result<int>> calculateBuildableQuantity(int productId);
  Future<Result<double>> calculateBomCost(int productId);
  Future<Result<List<Product>>> getProductsUsingMaterial(int materialId);
  Future<Result<bool>> hasOrdersUsingProduct(int productId);
  Future<Result<void>> deleteProduct(int id);

  // Standalone product stock operations
  Future<Result<void>> receiveProductStock({
    required int productId,
    required int quantity,
    required double pricePerUnit,
    String? reference,
  });
  Future<Result<void>> adjustProductStock({
    required int productId,
    required int newQuantityOnHand,
  });
  Future<Result<void>> reserveProductStock(int productId, int quantity);
  Future<Result<void>> releaseReservedProductStock(int productId, int quantity);
  Future<Result<void>> deductProductStock(int productId, int quantity);
  Future<Result<void>> restoreDeductedProductStock(int productId, int quantity);
  Future<Result<List<ProductStockMovement>>> getProductStockMovements(
      int productId);
  Future<Result<List<Product>>> getLowStockProducts();

  /// Every order line this product appears in, across all statuses.
  Future<Result<List<ProductSale>>> getProductSales(int productId);
}

class BomItemInput {
  final int materialId;
  final int quantityRequired;

  const BomItemInput({
    required this.materialId,
    required this.quantityRequired,
  });
}
