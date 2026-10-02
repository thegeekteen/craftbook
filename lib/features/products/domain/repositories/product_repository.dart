import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../entities/bom_item.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, List<Product>>> getActiveProducts();
  Future<Either<Failure, Product?>> getProductById(int id);
  Future<Either<Failure, List<BomItem>>> getBomItems(int productId);
  Future<Either<Failure, int>> createProduct({
    required String name,
    String? description,
    required double sellPrice,
  });
  Future<Either<Failure, void>> updateProduct({
    required int id,
    String? name,
    String? description,
    double? sellPrice,
    bool? isActive,
  });
  Future<Either<Failure, void>> saveBomItems(int productId, List<BomItemInput> items);
  Future<Either<Failure, int>> calculateBuildableQuantity(int productId);
  Future<Either<Failure, double>> calculateBomCost(int productId);
  Future<Either<Failure, List<Product>>> getProductsUsingMaterial(int materialId);
  Future<Either<Failure, void>> deleteProduct(int id);
}

class BomItemInput {
  final int materialId;
  final int quantityRequired;

  const BomItemInput({
    required this.materialId,
    required this.quantityRequired,
  });
}
