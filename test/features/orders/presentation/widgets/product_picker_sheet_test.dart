import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/widgets/product_photo.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/presentation/widgets/product_picker_sheet.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/localized_app.dart';

import '../../../../support/sample_data.dart';

void main() {
  testWidgets('rows show product photos and hand the photo to the order',
      (tester) async {
    await tester.runAsync(() async {
      await getIt.reset();
      await configureDependencies(
          database: AppDatabase.forTesting(NativeDatabase.memory()));
      await seedSampleShop();
    });

    final picked = <OrderItemInput>[];
    await tester.pumpWidget(localizedApp(
        Scaffold(body: ProductPickerSheet(onSelected: picked.add)),
        theme: AppTheme.lightTheme));
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }

    final tulipRow = find.ancestor(
        of: find.text('Crochet tulip bouquet'), matching: find.byType(Row));
    final tulipPhoto = tester.widget<ProductPhoto>(find
        .descendant(of: tulipRow, matching: find.byType(ProductPhoto))
        .first);
    expect(tulipPhoto.bytes, isNotNull);

    final strapRow = find.ancestor(
        of: find.text('Beaded phone strap'), matching: find.byType(Row));
    final strapPhoto = tester.widget<ProductPhoto>(find
        .descendant(of: strapRow, matching: find.byType(ProductPhoto))
        .first);
    expect(strapPhoto.bytes, isNull);

    await tester.tap(find.text('Crochet tulip bouquet'));
    expect(picked.single.productName, 'Crochet tulip bouquet');
    expect(picked.single.photo, tulipPhoto.bytes);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  });

  Future<void> pumpPicker(WidgetTester tester,
      {required void Function(OrderItemInput) onSelected,
      VoidCallback? onCreateNew}) async {
    await tester.pumpWidget(localizedApp(
        Scaffold(
            body: ProductPickerSheet(
                onSelected: onSelected, onCreateNew: onCreateNew)),
        theme: AppTheme.lightTheme));
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> freshShop(WidgetTester tester) => tester.runAsync(() async {
        await getIt.reset();
        await configureDependencies(
            database: AppDatabase.forTesting(NativeDatabase.memory()));
      });

  testWidgets('a product that is short can still be added, tagged Short',
      (tester) async {
    await freshShop(tester);
    await tester.runAsync(() => getIt<ProductRepository>()
        .createProduct(name: 'Birthday card', sellPrice: 120));

    final picked = <OrderItemInput>[];
    await pumpPicker(tester, onSelected: picked.add);
    expect(find.text('SHORT'), findsOneWidget);
    await tester.tap(find.text('Birthday card'));
    expect(picked.single.productName, 'Birthday card');

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  });

  testWidgets('offers to make a product, from the list and when there is none',
      (tester) async {
    await freshShop(tester);
    var asked = 0;
    await pumpPicker(tester, onSelected: (_) {}, onCreateNew: () => asked++);
    expect(find.text('No products yet'), findsOneWidget);
    await tester.tap(find.text('New product'));
    expect(asked, 1);

    await tester.runAsync(() => getIt<ProductRepository>()
        .createProduct(name: 'Birthday card', sellPrice: 120));
    // A fresh sheet, so it loads the product just made.
    await tester.pumpWidget(const SizedBox());
    await pumpPicker(tester, onSelected: (_) {}, onCreateNew: () => asked++);
    expect(find.text('Birthday card'), findsOneWidget);
    await tester.tap(find.text('New product'));
    expect(asked, 2);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  });
}
