import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/products/domain/usecases/update_product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repo;
  late UpdateProduct updateProduct;

  setUp(() {
    repo = MockProductRepository();
    updateProduct = UpdateProduct(repo);
    when(() => repo.updateProduct(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          sellPrice: any(named: 'sellPrice'),
          unitCost: any(named: 'unitCost'),
          isArchived: any(named: 'isArchived'),
          isStandalone: any(named: 'isStandalone'),
          alertLevel: any(named: 'alertLevel'),
        )).thenAnswer((_) async => const Success(null));
  });

  test('passes edited fields through, trimming the name', () async {
    final result = await updateProduct(
      id: 1,
      name: '  Tulip ',
      description: 'Pink',
      sellPrice: 450,
      unitCost: 12,
      alertLevel: 3,
    );
    expect(result, const Success<void>(null));
    verify(() => repo.updateProduct(
          id: 1,
          name: 'Tulip',
          description: 'Pink',
          sellPrice: 450,
          unitCost: 12,
          isArchived: null,
          isStandalone: null,
          alertLevel: 3,
        )).called(1);
  });

  test('rejects a blank name', () async {
    final r = await updateProduct(id: 1, name: ' ');
    expect((r as Error).failure, isA<ValidationFailure>());
  });

  test('rejects a price of 0', () async {
    expect(await updateProduct(id: 1, sellPrice: 0), isA<Error<void>>());
  });

  test('rejects a negative cost', () async {
    expect(await updateProduct(id: 1, unitCost: -1), isA<Error<void>>());
  });

  test('rejects a negative reorder level', () async {
    expect(await updateProduct(id: 1, alertLevel: -1), isA<Error<void>>());
  });
}
