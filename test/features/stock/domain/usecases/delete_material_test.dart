import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/entities/stock_movement.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:craftbook/features/stock/domain/usecases/delete_material.dart';

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late DeleteMaterial deleteMaterial;
  late MockMaterialRepository mockMaterialRepo;
  late MockProductRepository mockProductRepo;

  final testProduct = Product(
    id: 1,
    name: 'Test Product',
    sellPrice: 100,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final testMovement = StockMovement(
    id: 1,
    materialId: 1,
    orderId: null,
    type: StockMovementType.received,
    quantity: 10,
    unitCost: 5.0,
    createdAt: DateTime(2026, 1, 1),
    reference: 'Received',
  );

  setUp(() {
    mockMaterialRepo = MockMaterialRepository();
    mockProductRepo = MockProductRepository();
    deleteMaterial = DeleteMaterial(
      materialRepository: mockMaterialRepo,
      productRepository: mockProductRepo,
    );
  });

  group('DeleteMaterial', () {
    test('deletes material when not in use', () async {
      when(() => mockProductRepo.getProductsUsingMaterial(1))
          .thenAnswer((_) async => Success<List<Product>>([]));
      when(() => mockMaterialRepo.getStockMovements(1))
          .thenAnswer(
              (_) async => Success<List<StockMovement>>([]));
      when(() => mockMaterialRepo.deleteMaterial(1))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await deleteMaterial(1);

      expect(result, isA<Success<void>>());
      verify(() => mockMaterialRepo.deleteMaterial(1)).called(1);
    });

    test('blocks deletion when used in products (BOM)', () async {
      when(() => mockProductRepo.getProductsUsingMaterial(1))
          .thenAnswer(
              (_) async => Success<List<Product>>([testProduct]));

      final result = await deleteMaterial(1);

      expect(result, isA<Error<void>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('used in'));
        case Success():
          fail('Should return error');
      }
      verifyNever(() => mockMaterialRepo.deleteMaterial(any()));
    });

    test('blocks deletion when has stock movement history', () async {
      when(() => mockProductRepo.getProductsUsingMaterial(1))
          .thenAnswer((_) async => Success<List<Product>>([]));
      when(() => mockMaterialRepo.getStockMovements(1))
          .thenAnswer((_) async =>
              Success<List<StockMovement>>([testMovement]));

      final result = await deleteMaterial(1);

      expect(result, isA<Error<void>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('stock movement'));
        case Success():
          fail('Should return error');
      }
      verifyNever(() => mockMaterialRepo.deleteMaterial(any()));
    });
  });
}
