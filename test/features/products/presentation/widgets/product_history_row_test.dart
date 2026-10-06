import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/products/domain/entities/product_history_entry.dart';
import 'package:craftbook/features/products/domain/entities/product_sale.dart';
import 'package:craftbook/features/products/domain/entities/product_stock_movement.dart';
import 'package:craftbook/features/products/presentation/widgets/product_history_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

StockHistoryEntry _stock(ProductStockMovementType type, double qty,
        {String? reference}) =>
    StockHistoryEntry(ProductStockMovement(
      productId: 1,
      type: type,
      quantity: qty,
      unitCost: 28,
      createdAt: DateTime(2026, 3, 4),
      reference: reference,
    ));

void main() {
  testWidgets('received stock shows as an addition with its cost',
      (tester) async {
    await tester.pumpWidget(_wrap(ProductHistoryRow(
        entry: _stock(ProductStockMovementType.received, 5), unit: 'pc')));

    expect(find.text('Received'), findsOneWidget);
    expect(find.text('+5'), findsOneWidget);
    expect(find.textContaining('Mar 4, 2026'), findsOneWidget);
    expect(find.textContaining('/pc'), findsOneWidget);
  });

  testWidgets('initial stock and restored rows get their own titles',
      (tester) async {
    await tester.pumpWidget(_wrap(Column(children: [
      ProductHistoryRow(
          entry: _stock(ProductStockMovementType.received, 6,
              reference: 'Initial stock')),
      ProductHistoryRow(
        entry: _stock(ProductStockMovementType.received, 1,
            reference: 'Restored from deleted order'),
      ),
    ])));

    expect(find.text('Initial stock'), findsOneWidget);
    expect(find.text('Returned from deleted order'), findsOneWidget);
  });

  testWidgets('a count that lowered stock shows as a removal', (tester) async {
    await tester.pumpWidget(_wrap(ProductHistoryRow(
        entry: _stock(ProductStockMovementType.adjusted, -2))));

    expect(find.text('Counted'), findsOneWidget);
    expect(find.text('−2'), findsOneWidget);
  });

  testWidgets(
      'an order row shows customer, status and amount, and opens the order',
      (tester) async {
    int? opened;
    await tester.pumpWidget(_wrap(ProductHistoryRow(
      entry: SaleHistoryEntry(ProductSale(
        orderId: 12,
        customerName: 'Eli Ramos',
        status: OrderStatus.shipped,
        date: DateTime(2026, 3, 4),
        quantity: 2,
        unitPrice: 60,
        subtotal: 120,
      )),
      unit: 'pc',
      onOrderTap: (id) => opened = id,
    )));

    expect(find.text('#12 · Eli Ramos'), findsOneWidget);
    expect(find.text('SHIPPED'), findsOneWidget);
    expect(find.textContaining('2 pc ×'), findsOneWidget);
    expect(find.textContaining('120'), findsOneWidget);

    await tester.tap(find.text('#12 · Eli Ramos'));
    expect(opened, 12);
  });
}
