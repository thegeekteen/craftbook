import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/products/domain/entities/product_history_entry.dart';
import 'package:craftbook/features/products/domain/entities/product_sale.dart';
import 'package:craftbook/features/products/domain/entities/product_stock_movement.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/products/domain/usecases/get_product_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

ProductStockMovement _move(ProductStockMovementType type, DateTime at,
        {int qty = 3}) =>
    ProductStockMovement(
        productId: 1, type: type, quantity: qty, unitCost: 28, createdAt: at);

ProductSale _sale(int orderId, DateTime at) => ProductSale(
      orderId: orderId,
      customerName: 'Maria',
      status: OrderStatus.packed,
      date: at,
      quantity: 1,
      unitPrice: 60,
      subtotal: 60,
    );

List<ProductHistoryEntry> _entries(Result<List<ProductHistoryEntry>> r) =>
    switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

void main() {
  late MockProductRepository repo;
  late GetProductHistory getHistory;

  setUp(() {
    repo = MockProductRepository();
    getHistory = GetProductHistory(repo);
  });

  void stub({
    Result<List<ProductStockMovement>> movements = const Success([]),
    Result<List<ProductSale>> sales = const Success([]),
  }) {
    when(() => repo.getProductStockMovements(1))
        .thenAnswer((_) async => movements);
    when(() => repo.getProductSales(1)).thenAnswer((_) async => sales);
  }

  test('merges stock changes and orders, newest first', () async {
    final received =
        _move(ProductStockMovementType.received, DateTime(2026, 3, 1));
    final counted =
        _move(ProductStockMovementType.adjusted, DateTime(2026, 3, 9), qty: -1);
    final sale = _sale(7, DateTime(2026, 3, 5));
    stub(movements: Success([counted, received]), sales: Success([sale]));

    final result = await getHistory(1);

    expect(_entries(result), [
      StockHistoryEntry(counted),
      SaleHistoryEntry(sale),
      StockHistoryEntry(received),
    ]);
  });

  test('leaves out deducted movements, which the order row already covers',
      () async {
    final deducted =
        _move(ProductStockMovementType.deducted, DateTime(2026, 3, 5));
    final sale = _sale(7, DateTime(2026, 3, 5));
    stub(movements: Success([deducted]), sales: Success([sale]));

    final result = await getHistory(1);

    expect(_entries(result), [SaleHistoryEntry(sale)]);
  });

  test('fails when stock movements fail to load', () async {
    stub(movements: const Error(DatabaseFailure('disk')));

    expect(await getHistory(1),
        const Error<List<ProductHistoryEntry>>(DatabaseFailure('disk')));
  });

  test('fails when orders fail to load', () async {
    stub(sales: const Error(DatabaseFailure('disk')));

    expect(await getHistory(1),
        const Error<List<ProductHistoryEntry>>(DatabaseFailure('disk')));
  });
}
