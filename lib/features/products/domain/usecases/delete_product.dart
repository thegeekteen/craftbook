import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository productRepository;

  DeleteProduct({required this.productRepository});

  Future<Either<Failure, void>> call(int productId) async {
    final bomResult = await productRepository.getBomItems(productId);

    return bomResult.fold(
      (failure) => Left(failure),
      (bomItems) async {
        if (bomItems.isNotEmpty) {
          return Left(ValidationFailure(
            'Cannot delete product: has ${bomItems.length} BOM item(s). '
            'Remove the BOM first.',
          ));
        }

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
