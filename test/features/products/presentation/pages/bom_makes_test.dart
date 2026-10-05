import 'package:craftbook/app.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/widgets/stepper_input.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/products/presentation/widgets/product_profit_card.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

T _ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// A BOM line where one material piece makes several products: one A4
/// card sheet (₱3) makes 9 business cards.
void main() {
  late int cards;
  late int sheet;

  Future<void> start(WidgetTester tester, {double makes = 1}) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await getIt.reset();
      await configureDependencies(
          database: AppDatabase.forTesting(NativeDatabase.memory()));
      sheet = _ok(await getIt<MaterialRepository>().createMaterial(
        name: 'A4 card sheet',
        packSize: 50,
        packPrice: 150,
        unitCost: 3,
        quantityOnHand: 50,
        alertLevel: 5,
      ));
      final products = getIt<ProductRepository>();
      cards = _ok(
          await products.createProduct(name: 'Business cards', sellPrice: 3));
      _ok(await products.saveBomItems(cards, [
        BomItemInput(materialId: sheet, quantityRequired: 1, makes: makes),
      ]));
    });
  }

  Future<void> push(WidgetTester tester, String location) async {
    await tester.pumpWidget(CraftbookApp(initialLocation: RouteNames.products));
    await _settle(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push(location);
    await _settle(tester);
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  }

  testWidgets('the editor saves how many products a piece makes',
      (tester) async {
    await start(tester);
    await push(tester, RouteNames.productEditorPath(cards));

    expect(find.text('Uses'), findsOneWidget);
    expect(find.text('Makes'), findsOneWidget);
    final makes = find.descendant(
        of: find
            .ancestor(of: find.text('Makes'), matching: find.byType(Row))
            .first,
        matching: find.byType(StepperInput));
    await tester.enterText(
        find.descendant(of: makes, matching: find.byType(TextField)), '9');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    // ₱3.00 a sheet, a ninth of it per card.
    expect(find.textContaining('₱0.33'), findsWidgets);
    // The profit strip follows Makes too.
    await tester.scrollUntilVisible(find.byType(ProductProfitCard), 200,
        scrollable: find.byType(Scrollable).first);
    expect(
        tester.widget<ProductProfitCard>(find.byType(ProductProfitCard)).cost,
        closeTo(3 / 9, 1e-9));

    final save = find.widgetWithText(FilledButton, 'Save changes');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await _settle(tester);

    final bom = await tester.runAsync(
        () async => _ok(await getIt<ProductRepository>().getBomItems(cards)));
    expect((bom!.single.quantityRequired, bom.single.makes), (1, 9));
    await teardown(tester);
  });

  testWidgets('the product page costs a ninth of a sheet', (tester) async {
    await start(tester, makes: 9);
    await push(tester, RouteNames.productPath(cards));

    expect(find.textContaining('makes 9'), findsOneWidget);
    expect(find.textContaining('₱0.33'), findsWidgets);
    await teardown(tester);
  });

  testWidgets('the material page shows the share per product', (tester) async {
    await start(tester, makes: 9);
    await push(tester, RouteNames.materialPath(sheet));

    final usage = find.text('1 pc per 9');
    await tester.ensureVisible(usage);
    expect(usage, findsOneWidget);
    await teardown(tester);
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
