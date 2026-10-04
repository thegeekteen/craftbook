import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:craftbook/features/today/domain/usecases/get_alert_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockMaterialRepository materials;
  late MockProductRepository products;
  late GetAlertSummary useCase;
  final now = DateTime(2026, 1, 1);

  final yarn = Material(
    id: 1,
    name: 'Yarn',
    packSize: 10,
    packPrice: 100,
    unitCost: 10,
    quantityOnHand: 2,
    quantityPromised: 0,
    alertLevel: 5,
    createdAt: now,
    updatedAt: now,
  );
  final box = Product(
    id: 4,
    name: 'Kraft gift box',
    sellPrice: 60,
    isActive: true,
    isStandalone: true,
    quantityOnHand: 1,
    alertLevel: 3,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    materials = MockMaterialRepository();
    products = MockProductRepository();
    useCase = GetAlertSummary(materials, products);
  });

  test('counts low materials and low resell products, materials first',
      () async {
    when(() => materials.getLowStockMaterials())
        .thenAnswer((_) async => Success([yarn]));
    when(() => products.getLowStockProducts())
        .thenAnswer((_) async => Success([box]));

    final summary = switch (await useCase()) {
      Success(:final value) => value,
      Error() => fail('expected success'),
    };
    expect(summary.lowStockCount, 2);
    expect(summary.names, ['Yarn', 'Kraft gift box']);
    expect(summary.hasAlerts, isTrue);
  });

  test('no alerts when nothing is low', () async {
    when(() => materials.getLowStockMaterials())
        .thenAnswer((_) async => const Success([]));
    when(() => products.getLowStockProducts())
        .thenAnswer((_) async => const Success([]));

    final result = await useCase();
    expect(result, isA<Success<AlertSummary>>());
    expect((result as Success<AlertSummary>).value.hasAlerts, isFalse);
  });

  test('fails when materials fail', () async {
    when(() => materials.getLowStockMaterials())
        .thenAnswer((_) async => const Error(DatabaseFailure('boom')));
    when(() => products.getLowStockProducts())
        .thenAnswer((_) async => const Success([]));

    final result = await useCase();
    expect(result, isA<Error<AlertSummary>>());
  });

  test('fails when products fail', () async {
    when(() => materials.getLowStockMaterials())
        .thenAnswer((_) async => Success([yarn]));
    when(() => products.getLowStockProducts())
        .thenAnswer((_) async => const Error(DatabaseFailure('boom')));

    final result = await useCase();
    expect((result as Error<AlertSummary>).failure.message, 'boom');
  });
}
