import 'package:craftbook/app.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/widgets/choice_chip_row.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

T _ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Products filters, handmade alert levels and resell on the Buy list.
void main() {
  late int tulip;
  late int box;

  /// Yarn 2 on hand. Tulip (1 yarn, warn at 3) can make 2, so it's low.
  /// Strap (1 yarn, no alert) is never low. Gift box: 1 on hand, reorder
  /// at 3, so it's low and on the Buy list.
  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await getIt.reset();
      await configureDependencies(
          database: AppDatabase.forTesting(NativeDatabase.memory()));
      final materials = getIt<MaterialRepository>();
      final products = getIt<ProductRepository>();
      final yarn = _ok(await materials.createMaterial(
        name: 'Yarn',
        packSize: 10,
        packPrice: 100,
        unitCost: 10,
        quantityOnHand: 2,
        alertLevel: 1,
      ));
      Future<int> handmade(String name, {int alert = 0}) async {
        final id =
            _ok(await products.createProduct(name: name, sellPrice: 300));
        _ok(await products.saveBomItems(
            id, [BomItemInput(materialId: yarn, quantityRequired: 1)]));
        if (alert > 0) {
          _ok(await products.updateProduct(id: id, alertLevel: alert));
        }
        return id;
      }

      tulip = await handmade('Tulip', alert: 3);
      await handmade('Strap');
      box = _ok(await products.createProduct(
        name: 'Gift box',
        sellPrice: 60,
        isStandalone: true,
        initialQuantity: 1,
        initialUnitCost: 25,
      ));
      _ok(await products.updateProduct(id: box, alertLevel: 3));
    });
  }

  Future<void> open(WidgetTester tester, String location) async {
    await tester.pumpWidget(CraftbookApp(initialLocation: location));
    await _settle(tester);
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  }

  /// The chip row scrolls sideways; bring the chip on screen first.
  Future<void> tapChip(WidgetTester tester, String label) async {
    final chip = find.widgetWithText(AppChip, label);
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await _settle(tester);
  }

  /// Push [location] on top of the products list so the page can pop.
  Future<void> push(WidgetTester tester, String location) async {
    await open(tester, RouteNames.products);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push(location);
    await _settle(tester);
  }

  int? count(WidgetTester tester, String label) =>
      tester.widget<AppChip>(find.widgetWithText(AppChip, label)).count;

  group('Products list chips', () {
    testWidgets('counts each filter and hides Short when nothing is short',
        (tester) async {
      await start(tester);
      await open(tester, RouteNames.products);

      expect(count(tester, 'All'), 3);
      expect(count(tester, 'Handmade'), 2);
      expect(count(tester, 'Resell'), 1);
      expect(count(tester, 'Low'), 2);
      expect(find.widgetWithText(AppChip, 'Short'), findsNothing);
      await teardown(tester);
    });

    testWidgets('filters to resell, then to low', (tester) async {
      await start(tester);
      await open(tester, RouteNames.products);

      await tapChip(tester, 'Resell');
      expect(find.text('Gift box'), findsOneWidget);
      expect(find.text('Tulip'), findsNothing);
      expect(find.text('Strap'), findsNothing);

      await tapChip(tester, 'Low');
      expect(find.text('Gift box'), findsOneWidget);
      expect(find.text('Tulip'), findsOneWidget);
      expect(find.text('Strap'), findsNothing);
      await teardown(tester);
    });

    testWidgets('shows an empty state per filter', (tester) async {
      await start(tester);
      await tester.runAsync(() async {
        final products = getIt<ProductRepository>();
        _ok(await products.updateProduct(id: tulip, alertLevel: 0));
        _ok(await products.updateProduct(id: box, alertLevel: 0));
      });
      await open(tester, RouteNames.products);

      await tapChip(tester, 'Low');
      expect(find.text('Nothing is low'), findsOneWidget);
      await teardown(tester);
    });
  });

  group('Product editor', () {
    testWidgets('handmade products save a warning level', (tester) async {
      await start(tester);
      await push(tester, RouteNames.productEditorPath(tulip));

      final field =
          find.widgetWithText(TextFormField, 'Warn when I can make (optional)');
      expect(find.text('Reorder at (optional)'), findsNothing);
      // The editor body is a lazy ListView, so drag the field into view first.
      await tester.dragUntilVisible(
          field, find.byType(ListView), const Offset(0, -120));
      expect(field, findsOneWidget);
      await tester.ensureVisible(field);
      await tester.enterText(field, '5');
      await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
      await _settle(tester);

      final saved = await tester.runAsync(() async =>
          _ok(await getIt<ProductRepository>().getProductById(tulip)));
      expect(saved!.alertLevel, 5);
      await teardown(tester);
    });

    testWidgets('resell products keep the reorder wording', (tester) async {
      await start(tester);
      await open(tester, RouteNames.productEditorPath(box));

      expect(find.text('Reorder at (optional)'), findsOneWidget);
      expect(find.text('Warn when I can make (optional)'), findsNothing);
      await teardown(tester);
    });
  });

  group('Buy list', () {
    testWidgets('lists a low resell product by the piece', (tester) async {
      await start(tester);
      await open(tester, RouteNames.buyList);

      expect(find.text('Gift box'), findsOneWidget);
      expect(find.text('RESELL'), findsOneWidget);
      // Reorder at 3, has 1 → buy 2 pieces at ₱25.
      expect(find.textContaining('2 pc'), findsOneWidget);
      expect(find.textContaining('pack'), findsNothing);
      await teardown(tester);
    });

    testWidgets('copies resell lines in pieces', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));
      await start(tester);
      await open(tester, RouteNames.buyList);

      await tester.tap(find.text('Copy list'));
      await _settle(tester);
      expect(copied, contains('- Gift box: 2 pc, ₱50.00'));
      await teardown(tester);
    });

    testWidgets('tapping a resell line opens the product', (tester) async {
      await start(tester);
      await open(tester, RouteNames.buyList);

      await tester.tap(find.text('Gift box'));
      await _settle(tester);
      expect(find.text('PC ON HAND'), findsOneWidget);
      await teardown(tester);
    });
  });
}

/// Real database work runs outside the fake clock, so pump a fixed run of
/// frames instead of pumpAndSettle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
