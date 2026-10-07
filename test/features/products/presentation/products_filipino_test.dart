import 'package:craftbook/features/discounts/presentation/widgets/discount_sheet.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/presentation/product_list_filter.dart';
import 'package:craftbook/features/products/presentation/widgets/product_card.dart';
import 'package:craftbook/features/products/presentation/widgets/products_filter_sheet.dart';
import 'package:craftbook/features/units/presentation/widgets/unit_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/localized_app.dart';

const _fil = Locale('fil');

Product _product({bool archived = false}) => Product(
      id: 1,
      name: 'Tulip bouquet',
      sellPrice: 400,
      isArchived: archived,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  testWidgets('product card tags and cost read in Filipino', (tester) async {
    await tester.pumpWidget(localizedApp(
      Scaffold(
          body: ProductCard(product: _product(archived: true), unitCost: 100)),
      locale: _fil,
    ));
    expect(find.text('NAKA-ARCHIVE'), findsOneWidget);
    expect(find.textContaining('Puhunan', findRichText: true), findsOneWidget);
    expect(find.text('ARCHIVED'), findsNothing);
  });

  testWidgets('products filter sheet reads in Filipino', (tester) async {
    final view = ProductCatalogueView(
        products: [_product()], available: const {}, shortIds: const {});
    await tester.pumpWidget(localizedApp(
      Scaffold(
          body:
              ProductsFilterForm(current: ProductListFilter.none, view: view)),
      locale: _fil,
    ));
    expect(find.text('Uri'), findsOneWidget);
    expect(find.textContaining('Gawang-kamay'), findsOneWidget);
    expect(find.text('I-clear lahat'), findsOneWidget);
  });

  testWidgets('discount form validates in Filipino', (tester) async {
    await tester.pumpWidget(
        localizedApp(const Scaffold(body: DiscountForm()), locale: _fil));
    expect(find.text('Porsyentong bawas'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Pangalanan ang diskwento'), findsOneWidget);
  });

  testWidgets('unit form validates in Filipino', (tester) async {
    await tester.pumpWidget(
        localizedApp(const Scaffold(body: UnitForm()), locale: _fil));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Pangalanan ang unit'), findsOneWidget);
  });
}
