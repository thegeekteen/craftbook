import 'package:craftbook/core/error/result.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Active resell products at or below their alert level.
class GetLowStockProducts {
  final ProductRepository repository;

  GetLowStockProducts(this.repository);

  Future<Result<List<Product>>> call() => repository.getLowStockProducts();
}
