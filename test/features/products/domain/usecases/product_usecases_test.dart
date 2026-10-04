import 'package:craftbook/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/products/domain/usecases/create_product.dart';
import 'package:craftbook/features/products/domain/usecases/get_products.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late CreateProduct createProduct;
  late GetProducts getProducts;
  late MockProductRepository mockRepository;

  final testProduct = Product(
    id: 1,
    name: 'Custom Magnets',
    description: 'set of 3',
    sellPrice: 249.0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockProductRepository();
    createProduct = CreateProduct(mockRepository);
    getProducts = GetProducts(mockRepository);
  });

  group('CreateProduct', () {
    test('creates product successfully', () async {
      when(() => mockRepository.createProduct(
            name: any(named: 'name'),
            description: any(named: 'description'),
            sellPrice: any(named: 'sellPrice'),
            isStandalone: any(named: 'isStandalone'),
            initialQuantity: any(named: 'initialQuantity'),
            initialUnitCost: any(named: 'initialUnitCost'),
          )).thenAnswer((_) async => const Success<int>(1));
      when(() => mockRepository.getProductById(1))
          .thenAnswer((_) async => Success<Product?>(testProduct));

      final result = await createProduct(
        name: 'Custom Magnets',
        description: 'set of 3',
        sellPrice: 249.0,
      );

      expect(result, isA<Success<Product?>>());
      switch (result) {
        case Error():
          fail('Should not return error');
        case Success(:final value):
          expect(value, testProduct);
      }
    });

    test('returns validation failure when name is empty', () async {
      final result = await createProduct(
        name: '',
        sellPrice: 249.0,
      );

      expect(result, isA<Error<Product?>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
        case Success():
          fail('Should return error');
      }
    });

    test('returns validation failure when price is zero', () async {
      final result = await createProduct(
        name: 'Test',
        sellPrice: 0,
      );

      expect(result, isA<Error<Product?>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
        case Success():
          fail('Should return error');
      }
    });
  });

  group('GetProducts', () {
    test('returns all products', () async {
      when(() => mockRepository.getAllProducts())
          .thenAnswer((_) async => Success<List<Product>>([testProduct]));

      final result = await getProducts();

      expect(result, isA<Success<List<Product>>>());
      switch (result) {
        case Error():
          fail('Should not return error');
        case Success(:final value):
          expect(value, [testProduct]);
      }
    });

    test('leaves out archived products when asked', () async {
      when(() => mockRepository.getUnarchivedProducts())
          .thenAnswer((_) async => Success<List<Product>>([testProduct]));

      final result = await getProducts(includeArchived: false);

      expect(result, isA<Success<List<Product>>>());
      switch (result) {
        case Error():
          fail('Should not return error');
        case Success(:final value):
          expect(value, [testProduct]);
      }
    });
  });
}
