import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/widgets/choice_chip_row.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/presentation/product_list_filter.dart';
import 'package:craftbook/features/products/presentation/widgets/products_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime(2026, 1, 1);

Product _product(int id, String name,
        {bool resell = false, bool archived = false, double alert = 0}) =>
    Product(
      id: id,
      name: name,
      sellPrice: 100,
      isStandalone: resell,
      isArchived: archived,
      quantityOnHand: 1,
      alertLevel: alert,
      createdAt: _at,
      updatedAt: _at,
    );

void main() {
  ProductCatalogueView view(
          {Set<int> short = const {}, bool archived = false}) =>
      ProductCatalogueView(
        products: [
          _product(1, 'Tulip', alert: 3),
          _product(2, 'Strap'),
          _product(3, 'Gift box', resell: true, alert: 3),
          if (archived) _product(4, 'Old card', archived: true),
        ],
        available: const {1: 2, 2: 5},
        shortIds: short,
      );

  Future<ProductListFilter?> run(
    WidgetTester tester,
    ProductCatalogueView v,
    Future<void> Function() interact, {
    ProductListFilter current = ProductListFilter.none,
  }) async {
    ProductListFilter? result;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result =
              await showProductsFilterSheet(context, current: current, view: v),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await interact();
    await tester.pumpAndSettle();
    return result;
  }

  int? count(WidgetTester tester, String label) =>
      tester.widget<AppChip>(find.widgetWithText(AppChip, label)).count;

  testWidgets('counts every option and hides Short and Archived when empty',
      (tester) async {
    await run(tester, view(), () async {
      expect(find.text('Filter products'), findsOneWidget);
      expect(count(tester, 'Handmade'), 2);
      expect(count(tester, 'Resell'), 1);
      expect(count(tester, 'Low'), 2);
      expect(find.widgetWithText(AppChip, 'Short'), findsNothing);
      expect(find.widgetWithText(AppChip, 'Archived'), findsNothing);
    });
  });

  testWidgets('shows Short and Archived when there is something behind them',
      (tester) async {
    await run(tester, view(short: {2}, archived: true), () async {
      expect(count(tester, 'Short'), 1);
      expect(count(tester, 'Archived'), 1);
    });
  });

  testWidgets('combines a type and a stock choice', (tester) async {
    final f = await run(tester, view(), () async {
      await tester.tap(find.widgetWithText(AppChip, 'Handmade'));
      await tester.pumpAndSettle();
      // Of the handmade products, only Tulip is low.
      expect(count(tester, 'Low'), 1);
      await tester.tap(find.widgetWithText(AppChip, 'Low'));
      await tester.tap(find.text('Show'));
    });
    expect(
        f,
        const ProductListFilter(
            type: ProductTypeFilter.handmade, stock: ProductStockFilter.low));
  });

  testWidgets('Clear all goes back to no filter', (tester) async {
    final f = await run(
      tester,
      view(),
      () async {
        await tester.tap(find.text('Clear all'));
        await tester.tap(find.text('Show'));
      },
      current: const ProductListFilter(type: ProductTypeFilter.resell),
    );
    expect(f, ProductListFilter.none);
  });
}
