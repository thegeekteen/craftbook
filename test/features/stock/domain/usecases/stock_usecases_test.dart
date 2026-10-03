import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:craftbook/features/stock/domain/usecases/receive_stock.dart';
import 'package:craftbook/features/stock/domain/usecases/adjust_stock.dart';
import 'package:craftbook/features/stock/domain/usecases/get_materials.dart';

class MockMaterialRepository extends Mock implements MaterialRepository {}

void main() {
  late ReceiveStock receiveStock;
  late AdjustStock adjustStock;
  late GetMaterials getMaterials;
  late MockMaterialRepository mockRepository;

  final testMaterial = Material(
    id: 1,
    name: 'Magnet sheet',
    packSize: 20,
    packPrice: 180.0,
    unitCost: 9.0,
    quantityOnHand: 14,
    quantityPromised: 2,
    alertLevel: 20,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockMaterialRepository();
    receiveStock = ReceiveStock(mockRepository);
    adjustStock = AdjustStock(mockRepository);
    getMaterials = GetMaterials(mockRepository);
  });

  group('ReceiveStock', () {
    test('receives stock successfully', () async {
      when(() => mockRepository.receiveStock(
            materialId: any(named: 'materialId'),
            packsReceived: any(named: 'packsReceived'),
            pricePerPack: any(named: 'pricePerPack'),
          )).thenAnswer((_) async => const Success<void>(null));

      final result = await receiveStock(
        materialId: 1,
        packsReceived: 2,
        pricePerPack: 235.0,
      );

      expect(result, const Success<void>(null));
      verify(() => mockRepository.receiveStock(
            materialId: 1,
            packsReceived: 2,
            pricePerPack: 235.0,
          )).called(1);
    });

    test('returns validation failure when packs is zero', () async {
      final result = await receiveStock(
        materialId: 1,
        packsReceived: 0,
        pricePerPack: 235.0,
      );

      expect(result, isA<Error<void>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
        case Success():
          fail('Should not return success');
      }
    });

    test('returns validation failure when price is negative', () async {
      final result = await receiveStock(
        materialId: 1,
        packsReceived: 2,
        pricePerPack: -10.0,
      );

      expect(result, isA<Error<void>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
        case Success():
          fail('Should not return success');
      }
    });
  });

  group('AdjustStock', () {
    test('adjusts stock successfully', () async {
      when(() => mockRepository.adjustStock(1, 50))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await adjustStock(1, 50);

      expect(result, const Success<void>(null));
    });

    test('returns validation failure for negative quantity', () async {
      final result = await adjustStock(1, -5);

      expect(result, isA<Error<void>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
        case Success():
          fail('Should not return success');
      }
    });
  });

  group('GetMaterials', () {
    test('returns all materials', () async {
      when(() => mockRepository.getAllMaterials())
          .thenAnswer((_) async => Success<List<Material>>([testMaterial]));

      final result = await getMaterials();

      expect(result, isA<Success<List<Material>>>());
      switch (result) {
        case Error():
          fail('Should not return error');
        case Success(value: final materials):
          expect(materials, [testMaterial]);
      }
    });

    test('returns low stock materials only', () async {
      when(() => mockRepository.getLowStockMaterials())
          .thenAnswer((_) async => Success<List<Material>>([testMaterial]));

      final result = await getMaterials(lowStockOnly: true);

      expect(result, isA<Success<List<Material>>>());
      switch (result) {
        case Error():
          fail('Should not return error');
        case Success(value: final materials):
          expect(materials, [testMaterial]);
      }
    });
  });
}
