import 'package:craftbook/core/error/result.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository productRepository;

  DeleteProduct({required this.productRepository});

  Future<Result<void>> call(int productId) async {
    // Check if product exists and get its type
    final productResult = await productRepository.getProductById(productId);

    switch (productResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        final product = value;
        if (product == null) {
          return const Error(NotFoundFailure('Product not found'));
        }

        // For BOM products: check BOM items
        if (!product.isStandalone) {
          final bomResult = await productRepository.getBomItems(productId);
          switch (bomResult) {
            case Success(:final value) when value.isNotEmpty:
              final bomItems = value;
              return Error(ValidationFailure(
                'Cannot delete product: has ${bomItems.length} BOM item(s). '
                'Remove the BOM first.',
              ));
            default:
              break;
          }
        }

        // For standalone products: check stock on hand
        if (product.isStandalone && product.quantityOnHand > 0) {
          return Error(ValidationFailure(
            'Cannot delete product: has ${product.quantityOnHand} unit(s) in stock. '
            'Adjust stock to 0 first.',
          ));
        }

        // Check if referenced by orders
        final hasOrdersResult =
            await productRepository.hasOrdersUsingProduct(productId);

        switch (hasOrdersResult) {
          case Error(:final failure):
            return Error(failure);
          case Success(:final value):
            if (value) {
              return const Error(ValidationFailure(
                'Cannot delete product: referenced by existing orders. Archive it instead.',
              ));
            }
            return productRepository.deleteProduct(productId);
        }
    }
  }
}
