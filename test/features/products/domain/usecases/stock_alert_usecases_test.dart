import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/products/domain/usecases/get_low_stock_products.dart';
import 'package:craftbook/features/products/domain/usecases/get_pending_order_counts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repo;

  final box = Product(
    id: 4,
    name: 'Kraft gift box',
    sellPrice: 60,
    isActive: true,
    isStandalone: true,
    quantityOnHand: 2,
    alertLevel: 3,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() => repo = MockProductRepository());

  group('GetLowStockProducts', () {
    test('returns the repository list', () async {
      when(() => repo.getLowStockProducts())
          .thenAnswer((_) async => Success([box]));
      final result = await GetLowStockProducts(repo)();
      expect((result as Success<List<Product>>).value, [box]);
    });

    test('passes failures through', () async {
      when(() => repo.getLowStockProducts())
          .thenAnswer((_) async => const Error(DatabaseFailure('boom')));
      final result = await GetLowStockProducts(repo)();
      expect(result, const Error<List<Product>>(DatabaseFailure('boom')));
    });
  });

  group('GetPendingOrderCounts', () {
    test('returns counts by product id', () async {
      when(() => repo.getPendingOrderCounts())
          .thenAnswer((_) async => const Success({1: 2, 4: 1}));
      final result = await GetPendingOrderCounts(repo)();
      expect(result, const Success<Map<int, int>>({1: 2, 4: 1}));
    });

    test('passes failures through', () async {
      when(() => repo.getPendingOrderCounts())
          .thenAnswer((_) async => const Error(DatabaseFailure('boom')));
      final result = await GetPendingOrderCounts(repo)();
      expect(result, const Error<Map<int, int>>(DatabaseFailure('boom')));
    });
  });
}
