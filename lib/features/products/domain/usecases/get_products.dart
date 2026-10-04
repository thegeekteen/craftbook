import 'package:craftbook/core/error/result.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  /// Pickers pass [includeArchived] false; lists load everything and let
  /// the user choose whether to see archived products.
  Future<Result<List<Product>>> call({bool includeArchived = true}) async {
    if (!includeArchived) {
      return repository.getUnarchivedProducts();
    }
    return repository.getAllProducts();
  }
}
