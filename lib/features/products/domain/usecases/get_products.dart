import 'package:craftbook/core/error/result.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<Result<List<Product>>> call({bool activeOnly = false}) async {
    if (activeOnly) {
      return repository.getActiveProducts();
    }
    return repository.getAllProducts();
  }
}
