import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../entities/bom_item.dart';
import '../entities/product_stock_movement.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, List<Product>>> getActiveProducts();
  Future<Either<Failure, Product?>> getProductById(int id);
  Future<Either<Failure, List<BomItem>>> getBomItems(int productId);
  Future<Either<Failure, int>> createProduct({
    required String name,
    String? description,
    required double sellPrice,
    bool isStandalone,
    int initialQuantity,
    double initialUnitCost,
  });
  Future<Either<Failure, void>> updateProduct({
    required int id,
    String? name,
    String? description,
    double? sellPrice,
    bool? isActive,
    bool? isStandalone,
    int? alertLevel,
  });
  Future<Either<Failure, void>> saveBomItems(int productId, List<BomItemInput> items);
  Future<Either<Failure, int>> calculateBuildableQuantity(int productId);
  Future<Either<Failure, double>> calculateBomCost(int productId);
  Future<Either<Failure, List<Product>>> getProductsUsingMaterial(int materialId);
  Future<Either<Failure, bool>> hasOrdersUsingProduct(int productId);
  Future<Either<Failure, void>> deleteProduct(int id);

  // Standalone product stock operations
  Future<Either<Failure, void>> receiveProductStock({
    required int productId,
    required int quantity,
    required double pricePerUnit,
    String? reference,
  });
  Future<Either<Failure, void>> adjustProductStock({
    required int productId,
    required int newQuantityOnHand,
  });
  Future<Either<Failure, void>> reserveProductStock(int productId, int quantity);
  Future<Either<Failure, void>> releaseReservedProductStock(int productId, int quantity);
  Future<Either<Failure, void>> deductProductStock(int productId, int quantity);
  Future<Either<Failure, void>> restoreDeductedProductStock(int productId, int quantity);
  Future<Either<Failure, List<ProductStockMovement>>> getProductStockMovements(int productId);
  Future<Either<Failure, List<Product>>> getLowStockProducts();
}

class BomItemInput {
  final int materialId;
  final int quantityRequired;

  const BomItemInput({
    required this.materialId,
    required this.quantityRequired,
  });
}
