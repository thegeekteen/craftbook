import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/discounts/domain/entities/discount_preset.dart';
import 'package:craftbook/features/orders/domain/entities/order_discount.dart';
import 'package:craftbook/features/orders/presentation/widgets/order_terms_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/localized_app.dart';

void main() {
  const loyal = DiscountPreset(
      id: 1, label: 'Loyal', kind: DiscountKind.percent, value: 10);
  const vat = OrderTax(rate: 12, inclusive: true);

  late List<Object> calls;

  Future<void> pump(WidgetTester tester,
      {OrderTerms terms = const OrderTerms(),
      OrderTax? availableTax,
      List<DiscountPreset> presets = const [loyal]}) async {
    calls = [];
    await tester.pumpWidget(localizedApp(
        Scaffold(
          body: SingleChildScrollView(
            child: OrderTermsCard(
              itemsTotal: 1000,
              terms: terms,
              availableTax: availableTax,
              taxLabel: 'VAT',
              presets: presets,
              onAddDiscount: calls.add,
              onRemoveDiscount: (i) => calls.add('remove $i'),
              onTaxChanged: (on) => calls.add('tax $on'),
              onPaidChanged: (paid) => calls.add('paid $paid'),
            ),
          ),
        ),
        theme: AppTheme.lightTheme));
  }

  testWidgets('a preset chip adds that discount', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Loyal −10%'));
    expect(calls, [loyal.toDiscount()]);
  });

  testWidgets('lists discounts with what they take off', (tester) async {
    await pump(tester, terms: OrderTerms(discounts: [loyal.toDiscount()]));
    expect(find.text('Loyal · 10%'), findsOneWidget);
    expect(find.text('−₱100.00'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove Loyal'));
    expect(calls, ['remove 0']);
  });

  testWidgets('no tax switch when the shop has no tax', (tester) async {
    await pump(tester);
    expect(find.textContaining('VAT'), findsNothing);
  });

  testWidgets('tax switch shows the amount and can be turned off',
      (tester) async {
    await pump(tester, terms: const OrderTerms(tax: vat), availableTax: vat);
    expect(find.text('VAT 12% · in prices'), findsOneWidget);
    expect(find.text('₱107.14 of the total is VAT'), findsOneWidget);
    await tester.tap(find.text('VAT 12% · in prices'));
    expect(calls, ['tax false']);
  });

  testWidgets('unpaid says how much is owed', (tester) async {
    await pump(tester,
        terms: OrderTerms(discounts: [loyal.toDiscount()], isPaid: false));
    expect(find.text('Waiting for ₱900.00'), findsOneWidget);
    await tester.tap(find.text('Paid'));
    expect(calls, ['paid true']);
  });

  testWidgets('with no presets, offers to add one', (tester) async {
    await pump(tester, presets: const []);
    expect(find.text('+ Add discount'), findsOneWidget);
  });
}
