import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/widgets/product_photo.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/presentation/widgets/product_picker_sheet.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: ProductPickerSheet(onSelected: picked.add)),
    ));
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
}
