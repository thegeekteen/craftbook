import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository productRepository;

  DeleteProduct({required this.productRepository});

  Future<Either<Failure, void>> call(int productId) async {
    // Check if product exists and get its type
    final productResult = await productRepository.getProductById(productId);

    return productResult.fold(
      (failure) => Left(failure),
      (product) async {
        if (product == null) {
          return Left(NotFoundFailure('Product not found'));
        }

        // For BOM products: check BOM items
        if (!product.isStandalone) {
          final bomResult = await productRepository.getBomItems(productId);
          final bomBlocked = bomResult.fold<bool>(
            (_) => false,
            (bomItems) => bomItems.isNotEmpty,
          );
          if (bomBlocked) {
            final bomItems = bomResult.fold((_) => <dynamic>[], (items) => items);
            return Left(ValidationFailure(
              'Cannot delete product: has ${bomItems.length} BOM item(s). '
              'Remove the BOM first.',
            ));
          }
        }

        // For standalone products: check stock on hand
        if (product.isStandalone && product.quantityOnHand > 0) {
          return Left(ValidationFailure(
            'Cannot delete product: has ${product.quantityOnHand} unit(s) in stock. '
            'Adjust stock to 0 first.',
          ));
        }

        // Check if referenced by orders
        final hasOrdersResult =
            await productRepository.hasOrdersUsingProduct(productId);

        return hasOrdersResult.fold(
          (failure) => Left(failure),
          (hasOrders) async {
            if (hasOrders) {
              return const Left(ValidationFailure(
                'Cannot delete product: referenced by existing orders',
              ));
            }

            return productRepository.deleteProduct(productId);
          },
        );
      },
    );
  }
}
