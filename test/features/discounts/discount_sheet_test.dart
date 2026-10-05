import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/discounts/presentation/widgets/discount_sheet.dart';
import 'package:craftbook/features/orders/domain/entities/order_discount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<OrderDiscount?> run(
      WidgetTester tester, Future<void> Function() interact,
      {OrderDiscount? initial}) async {
    OrderDiscount? result;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showDiscountSheet(context,
              title: 'Add a discount', initial: initial),
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

  testWidgets('returns a percent discount', (tester) async {
    final d = await run(tester, () async {
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Loyal');
      await tester.enterText(
          find.widgetWithText(TextField, 'Percent off'), '10');
      await tester.tap(find.text('Save'));
    });
    expect(
        d,
        const OrderDiscount(
            label: 'Loyal', kind: DiscountKind.percent, value: 10));
  });

  testWidgets('switches to a fixed amount', (tester) async {
    final d = await run(tester, () async {
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Promo');
      await tester.tap(find.text('Fixed amount'));
      await tester.pump();
      await tester.enterText(
          find.widgetWithText(TextField, 'Amount off'), '50');
      await tester.tap(find.text('Save'));
    });
    expect(d?.kind, DiscountKind.fixed);
    expect(d?.value, 50);
  });

  testWidgets('shows why it cannot save and stays open', (tester) async {
    final d = await run(tester, () async {
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Big');
      await tester.enterText(
          find.widgetWithText(TextField, 'Percent off'), '150');
      await tester.tap(find.text('Save'));
    });
    expect(d, isNull);
    expect(find.text('A percentage can be at most 100'), findsOneWidget);
  });

  testWidgets('starts from an existing discount', (tester) async {
    await run(tester, () async {},
        initial: const OrderDiscount(
            label: 'Bundle', kind: DiscountKind.fixed, value: 25));
    expect(find.text('Bundle'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Amount off'), findsOneWidget);
  });
}
