import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:craftbook/features/stock/domain/usecases/update_material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMaterialRepository extends Mock implements MaterialRepository {}

void main() {
  late MockMaterialRepository repo;
  late UpdateMaterial updateMaterial;

  setUp(() {
    repo = MockMaterialRepository();
    updateMaterial = UpdateMaterial(repo);
    when(() => repo.updateMaterial(
          id: any(named: 'id'),
          name: any(named: 'name'),
          packSize: any(named: 'packSize'),
          packPrice: any(named: 'packPrice'),
          alertLevel: any(named: 'alertLevel'),
          supplier: any(named: 'supplier'),
        )).thenAnswer((_) async => const Success(null));
  });

  Future<Result<void>> call({
    String name = 'Beads',
    int packSize = 100,
    double packPrice = 50,
    int alertLevel = 10,
    String? supplier,
  }) =>
      updateMaterial(
        id: 1,
        name: name,
        packSize: packSize,
        packPrice: packPrice,
        alertLevel: alertLevel,
        supplier: supplier,
      );

  test('trims text and delegates to the repository', () async {
    expect(await call(name: '  Beads ', supplier: '  Shopee '),
        const Success<void>(null));
    verify(() => repo.updateMaterial(
          id: 1,
          name: 'Beads',
          packSize: 100,
          packPrice: 50,
          alertLevel: 10,
          supplier: 'Shopee',
        )).called(1);
  });

  test('blank supplier is stored as null', () async {
    await call(supplier: '   ');
    verify(() => repo.updateMaterial(
          id: 1,
          name: 'Beads',
          packSize: 100,
          packPrice: 50,
          alertLevel: 10,
          supplier: null,
        )).called(1);
  });

  group('validation', () {
    test('rejects a blank name', () async {
      expect(await call(name: '  '), isA<Error<void>>());
    });
    test('rejects pack size 0', () async {
      final r = await call(packSize: 0);
      expect(r, isA<Error<void>>());
      expect((r as Error).failure, isA<ValidationFailure>());
    });
    test('rejects a negative price', () async {
      expect(await call(packPrice: -1), isA<Error<void>>());
    });
    test('rejects a negative reorder level', () async {
      expect(await call(alertLevel: -1), isA<Error<void>>());
    });
    test('never reaches the repository when invalid', () async {
      await call(packSize: 0);
      verifyNever(() => repo.updateMaterial(
            id: any(named: 'id'),
            name: any(named: 'name'),
            packSize: any(named: 'packSize'),
            packPrice: any(named: 'packPrice'),
            alertLevel: any(named: 'alertLevel'),
            supplier: any(named: 'supplier'),
          ));
    });
  });
}
