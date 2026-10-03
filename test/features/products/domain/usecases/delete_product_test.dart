import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/features/products/domain/entities/bom_item.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/products/domain/usecases/delete_product.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late DeleteProduct deleteProduct;
  late MockProductRepository mockRepo;

  final bomProduct = Product(
    id: 1,
    name: 'Test Product',
    sellPrice: 100.0,
    isActive: true,
    isStandalone: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final testBomItem = BomItem(
    id: 1,
    productId: 1,
    materialId: 10,
    materialName: 'Mat',
    materialUnitCost: 5.0,
    quantityRequired: 2,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepo = MockProductRepository();
    deleteProduct = DeleteProduct(productRepository: mockRepo);

    // Default: return a non-standalone product
    when(() => mockRepo.getProductById(1))
        .thenAnswer((_) async => Right<Failure, Product?>(bomProduct));
  });

  group('DeleteProduct', () {
    test('deletes product when not in use', () async {
      when(() => mockRepo.getBomItems(1))
          .thenAnswer((_) async => Right<Failure, List<BomItem>>([]));
      when(() => mockRepo.hasOrdersUsingProduct(1))
          .thenAnswer((_) async => const Right<Failure, bool>(false));
      when(() => mockRepo.deleteProduct(1))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await deleteProduct(1);

      expect(result.isRight(), true);
      verify(() => mockRepo.deleteProduct(1)).called(1);
    });

    test('blocks deletion when has BOM items', () async {
      when(() => mockRepo.getBomItems(1))
          .thenAnswer(
              (_) async => Right<Failure, List<BomItem>>([testBomItem]));

      final result = await deleteProduct(1);

      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<ValidationFailure>());
          expect(f.message, contains('BOM'));
        },
        (_) => fail('Should return left'),
      );
      verifyNever(() => mockRepo.deleteProduct(any()));
    });

    test('blocks deletion when referenced by orders', () async {
      when(() => mockRepo.getBomItems(1))
          .thenAnswer((_) async => Right<Failure, List<BomItem>>([]));
      when(() => mockRepo.hasOrdersUsingProduct(1))
          .thenAnswer((_) async => const Right<Failure, bool>(true));

      final result = await deleteProduct(1);

      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<ValidationFailure>());
          expect(f.message, contains('orders'));
        },
        (_) => fail('Should return left'),
      );
      verifyNever(() => mockRepo.deleteProduct(any()));
    });
  });
}
