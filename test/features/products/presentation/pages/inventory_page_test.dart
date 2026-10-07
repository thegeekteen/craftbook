import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/widgets/choice_chip_row.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/app_harness.dart';

/// The Inventory tab, Products with Materials beside it: tabs, the app-bar filter and
/// the chips it leaves behind.
void main() {
  /// Yarn is plenty, Glue is low. Tulip is handmade, Gift box is resell.
  Future<void> seed() async {
    final materials = getIt<MaterialRepository>();
    final products = getIt<ProductRepository>();
    final yarn = ok(await materials.createMaterial(
        name: 'Yarn',
        packSize: 10,
        packPrice: 100,
        unitCost: 10,
        quantityOnHand: 20,
        alertLevel: 2));
    ok(await materials.createMaterial(
        name: 'Glue',
        packSize: 1,
        packPrice: 30,
        unitCost: 30,
        quantityOnHand: 1,
        alertLevel: 2));
    final tulip =
        ok(await products.createProduct(name: 'Tulip', sellPrice: 300));
    ok(await products.saveBomItems(
        tulip, [BomItemInput(materialId: yarn, quantityRequired: 1)]));
    ok(await products.createProduct(
        name: 'Gift box', sellPrice: 60, isStandalone: true));
  }

  Finder tab(String label) => find.widgetWithText(Tab, label);
  Finder tabCount(String label) =>
      find.descendant(of: tab(label), matching: find.byType(AnimatedContainer));
  bool badgeShown(WidgetTester tester) =>
      tester.widget<Badge>(find.byType(Badge)).isLabelVisible;

  Future<void> filter(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Filter'));
    await settle(tester);
    await tester.tap(find.widgetWithText(AppChip, label).last);
    await settle(tester);
    await tester.tap(find.text('Show'));
    await settle(tester);
  }

  testWidgets('opens on Products; the FAB follows the tab', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.products);
    expect(find.text('Tulip'), findsOneWidget);
    expect(find.text('Product'), findsOneWidget);

    await tester.tap(tab('Materials'));
    await settle(tester);
    expect(find.text('Glue'), findsOneWidget);
    expect(find.text('Material'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('each tab counts what it shows under its search and filter',
      (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.products);
    expect(find.text('Inventory'), findsWidgets);
    expect(tabCount('Products'), findsOneWidget);
    expect(find.descendant(of: tab('Products'), matching: find.text('2')),
        findsOneWidget);
    expect(find.descendant(of: tab('Materials'), matching: find.text('2')),
        findsOneWidget);

    await filter(tester, 'Resell');
    expect(find.descendant(of: tab('Products'), matching: find.text('1')),
        findsOneWidget);
    // The other tab's count is its own.
    expect(find.descendant(of: tab('Materials'), matching: find.text('2')),
        findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('/materials lands on the Materials tab', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.materials);
    expect(find.text('Glue'), findsOneWidget);
    expect(find.text('Yarn'), findsOneWidget);
    expect(find.text('Material'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('each tab keeps its own filter, and the badge follows the tab',
      (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.products);
    expect(badgeShown(tester), isFalse);

    await filter(tester, 'Resell');
    expect(badgeShown(tester), isTrue);
    expect(find.text('Gift box'), findsOneWidget);
    expect(find.text('Tulip'), findsNothing);

    await tester.tap(tab('Materials'));
    await settle(tester);
    expect(badgeShown(tester), isFalse);
    await filter(tester, 'Low');
    expect(find.text('Glue'), findsOneWidget);
    expect(find.text('Yarn'), findsNothing);

    await tester.tap(tab('Products'));
    await settle(tester);
    expect(badgeShown(tester), isTrue);
    expect(find.widgetWithText(AppChip, 'Resell'), findsOneWidget);
    expect(find.text('Tulip'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('a chip removes its filter', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.materials);
    await filter(tester, 'Low');
    expect(find.text('Yarn'), findsNothing);

    await tester.tap(find.widgetWithText(AppChip, 'Low'));
    await settle(tester);
    expect(find.widgetWithText(AppChip, 'Low'), findsNothing);
    expect(find.text('Yarn'), findsOneWidget);
    expect(badgeShown(tester), isFalse);
    await closeApp(tester);
  });

  testWidgets('each tab keeps its own search', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.products);
    await tester.enterText(find.byType(TextField).first, 'gift');
    await settle(tester);
    expect(find.text('Tulip'), findsNothing);

    await tester.tap(tab('Materials'));
    await settle(tester);
    expect(find.text('Yarn'), findsOneWidget);
    expect(find.text('Glue'), findsOneWidget);

    await tester.tap(tab('Products'));
    await settle(tester);
    expect(find.text('Gift box'), findsOneWidget);
    expect(find.text('Tulip'), findsNothing);
    await closeApp(tester);
  });
}
