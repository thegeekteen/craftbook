import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/theme/colors.dart';
import 'package:craftbook/core/widgets/money_breakdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  group('MoneyParts', () {
    test('profit is sales minus materials, fees and shipping', () {
      const parts =
          MoneyParts(sales: 500, materials: 120, fees: 50, shipping: 30);
      expect(parts.costs, 200);
      expect(parts.profit, 300);
      expect(parts.margin, closeTo(0.6, 1e-9));
    });

    test('margin is zero when there are no sales', () {
      const parts = MoneyParts(sales: 0, materials: 40, fees: 0, shipping: 0);
      expect(parts.profit, -40);
      expect(parts.margin, 0);
    });

    test('margin is negative when costs exceed sales', () {
      const parts =
          MoneyParts(sales: 100, materials: 150, fees: 0, shipping: 0);
      expect(parts.profit, -50);
      expect(parts.margin, closeTo(-0.5, 1e-9));
    });
  });

  group('MoneyBreakdownBar', () {
    testWidgets('renders one coloured segment per non-zero part',
        (tester) async {
      await tester.pumpWidget(_wrap(const MoneyBreakdownBar(
        parts: MoneyParts(sales: 500, materials: 100, fees: 50, shipping: 50),
      )));
      final bar = find.byType(MoneyBreakdownBar);
      // materials, fees, shipping, profit
      expect(find.descendant(of: bar, matching: find.byType(Expanded)),
          findsNWidgets(4));
    });

    testWidgets('skips zero parts', (tester) async {
      await tester.pumpWidget(_wrap(const MoneyBreakdownBar(
        parts: MoneyParts(sales: 500, materials: 100, fees: 0, shipping: 0),
      )));
      final bar = find.byType(MoneyBreakdownBar);
      expect(find.descendant(of: bar, matching: find.byType(Expanded)),
          findsNWidgets(2));
    });

    testWidgets('zero total renders a placeholder without error',
        (tester) async {
      await tester.pumpWidget(_wrap(const MoneyBreakdownBar(
        parts: MoneyParts(sales: 0, materials: 0, fees: 0, shipping: 0),
      )));
      expect(tester.takeException(), isNull);
      final bar = find.byType(MoneyBreakdownBar);
      expect(find.descendant(of: bar, matching: find.byType(Expanded)),
          findsNothing);
      expect(find.descendant(of: bar, matching: find.byType(ColoredBox)),
          findsOneWidget);
    });

    testWidgets('negative profit does not throw and drops the profit segment',
        (tester) async {
      await tester.pumpWidget(_wrap(const MoneyBreakdownBar(
        parts: MoneyParts(sales: 100, materials: 150, fees: 20, shipping: 10),
      )));
      expect(tester.takeException(), isNull);
      final bar = find.byType(MoneyBreakdownBar);
      expect(find.descendant(of: bar, matching: find.byType(Expanded)),
          findsNWidgets(3));
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(_wrap(const Center(
        child: SizedBox(
          width: 200,
          child: MoneyBreakdownBar(
            parts: MoneyParts(sales: 10, materials: 1, fees: 1, shipping: 1),
            height: 8,
          ),
        ),
      )));
      expect(tester.getSize(find.byType(MoneyBreakdownBar)).height, 8);
    });
  });

  group('MoneyBreakdown', () {
    const parts =
        MoneyParts(sales: 500, materials: 120, fees: 50, shipping: 30);

    testWidgets('shows rows with minus-signed costs', (tester) async {
      await tester.pumpWidget(_wrap(const MoneyBreakdown(
        parts: parts,
        feesLabel: 'Shopee fees',
      )));
      expect(find.text('Sales'), findsOneWidget);
      expect(find.text('₱500.00'), findsOneWidget);
      expect(find.text('Materials'), findsOneWidget);
      expect(find.text('−₱120.00'), findsOneWidget);
      expect(find.text('Shopee fees'), findsOneWidget);
      expect(find.text('−₱50.00'), findsOneWidget);
      expect(find.text('Shipping'), findsOneWidget);
      expect(find.text('−₱30.00'), findsOneWidget);
      expect(find.byType(MoneyBreakdownBar), findsOneWidget);
    });

    testWidgets('default labels and hidden bar', (tester) async {
      await tester.pumpWidget(_wrap(const MoneyBreakdown(
        parts: parts,
        showBar: false,
        materialsLabel: 'Pieces',
      )));
      expect(find.text('Channel fees'), findsOneWidget);
      expect(find.text('Pieces'), findsOneWidget);
      expect(find.byType(MoneyBreakdownBar), findsNothing);
    });

    testWidgets('no chevron without onMaterialsTap', (tester) async {
      await tester.pumpWidget(_wrap(const MoneyBreakdown(parts: parts)));
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    testWidgets('onMaterialsTap shows a chevron and fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(MoneyBreakdown(
        parts: parts,
        onMaterialsTap: () => taps++,
      )));
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      await tester.tap(find.text('Materials'));
      expect(taps, 1);
    });

    testWidgets('renders without an app theme (fallback palette)',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: MoneyBreakdown(parts: parts)),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('Sales'), findsOneWidget);
    });
  });

  group('MoneyRow', () {
    testWidgets('positive amount has no sign', (tester) async {
      await tester
          .pumpWidget(_wrap(const MoneyRow(label: 'Profit', amount: 42)));
      expect(find.text('Profit'), findsOneWidget);
      expect(find.text('₱42.00'), findsOneWidget);
    });

    testWidgets('negative amount uses the minus sign', (tester) async {
      await tester
          .pumpWidget(_wrap(const MoneyRow(label: 'Loss', amount: -7.5)));
      expect(find.text('−₱7.50'), findsOneWidget);
    });

    testWidgets('dot renders when given', (tester) async {
      await tester.pumpWidget(_wrap(const MoneyRow(
        label: 'Fees',
        amount: 1,
        dot: Colors.red,
      )));
      final dots = find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).shape == BoxShape.circle &&
          (w.decoration as BoxDecoration).color == Colors.red);
      expect(dots, findsOneWidget);
    });

    testWidgets('tappable row fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(MoneyRow(
        label: 'Tap me',
        amount: 1,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });
  });

  group('ProfitRow', () {
    testWidgets('shows profit and margin in green', (tester) async {
      await tester.pumpWidget(_wrap(const ProfitRow(
        parts: MoneyParts(sales: 500, materials: 120, fees: 50, shipping: 30),
      )));
      expect(find.text('Profit · 60% margin'), findsOneWidget);
      final amount = tester.widget<Text>(find.text('₱300.00'));
      expect(amount.style?.color,
          AppTheme.lightTheme.extension<CraftColors>()!.go);
    });

    testWidgets('a loss is signed and red', (tester) async {
      await tester.pumpWidget(_wrap(const ProfitRow(
        parts: MoneyParts(sales: 100, materials: 150, fees: 0, shipping: 0),
      )));
      expect(find.text('Profit · -50% margin'), findsOneWidget);
      final amount = tester.widget<Text>(find.text('−₱50.00'));
      expect(amount.style?.color,
          AppTheme.lightTheme.extension<CraftColors>()!.alert);
    });
  });
}
