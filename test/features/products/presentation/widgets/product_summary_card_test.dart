import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/theme/colors.dart';
import 'package:craftbook/core/utils/currency_formatter.dart';
import 'package:craftbook/core/widgets/pip_strip.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/presentation/widgets/product_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/sample_photo.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

final _now = DateTime(2026, 1, 1);

Product _product({
  bool standalone = false,
  bool active = true,
  int onHand = 0,
  int promised = 0,
  int alertLevel = 0,
  String? description,
}) =>
    Product(
      id: 1,
      name: 'Tulip bouquet',
      description: description,
      sellPrice: 400,
      isActive: active,
      isStandalone: standalone,
      quantityOnHand: onHand,
      quantityPromised: promised,
      alertLevel: alertLevel,
      createdAt: _now,
      updatedAt: _now,
    );

Color? _colorOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

CraftColors _colors(WidgetTester tester) =>
    tester.element(find.byType(ProductSummaryCard)).colors;

void main() {
  group('ProductSummaryCard resell', () {
    testWidgets('shows on hand, pips and stock stats', (tester) async {
      await tester.pumpWidget(_wrap(ProductSummaryCard(
        product:
            _product(standalone: true, onHand: 12, promised: 3, alertLevel: 4),
        cost: 100,
      )));

      expect(find.text('12'), findsOneWidget);
      expect(find.text('PCS ON HAND'), findsOneWidget);
      expect(find.byType(PipStrip), findsOneWidget);
      expect(find.text('FREE'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('PROMISED'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('REORDER AT'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('RESELL'), findsOneWidget);
      expect(find.text('LOW'), findsNothing);
    });

    testWidgets('flags low stock and shows a shortfall', (tester) async {
      await tester.pumpWidget(_wrap(ProductSummaryCard(
        product:
            _product(standalone: true, onHand: 2, promised: 5, alertLevel: 4),
        cost: 100,
      )));

      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('SHORT'), findsOneWidget);
      expect(_colorOf(tester, '2'), _colors(tester).alert);
    });
  });

  group('ProductSummaryCard handmade', () {
    testWidgets('shows can-build count without pips', (tester) async {
      await tester.pumpWidget(_wrap(
          ProductSummaryCard(product: _product(), cost: 100, buildable: 8)));

      expect(find.text('8'), findsOneWidget);
      expect(find.text('CAN BUILD'), findsOneWidget);
      expect(find.byType(PipStrip), findsNothing);
      expect(find.text('RESELL'), findsNothing);
      expect(find.text('LOW'), findsNothing);
    });

    testWidgets('shows zero buildable in alert colour', (tester) async {
      await tester.pumpWidget(
          _wrap(ProductSummaryCard(product: _product(), cost: 100)));

      expect(_colorOf(tester, '0'), _colors(tester).alert);
      expect(find.text('LOW'), findsNothing);
    });

    testWidgets('flags low at its alert level and shows Warn at',
        (tester) async {
      await tester.pumpWidget(_wrap(ProductSummaryCard(
          product: _product(alertLevel: 3), cost: 100, buildable: 3)));

      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('WARN AT'), findsOneWidget);
    });

    testWidgets('no alert level means no Low and no Warn at', (tester) async {
      await tester.pumpWidget(_wrap(
          ProductSummaryCard(product: _product(), cost: 100, buildable: 1)));

      expect(find.text('LOW'), findsNothing);
      expect(find.text('WARN AT'), findsNothing);
    });

    testWidgets('short shows the Short tag in alert colour', (tester) async {
      await tester.pumpWidget(_wrap(ProductSummaryCard(
          product: _product(), cost: 100, buildable: 4, isShort: true)));

      expect(find.text('SHORT'), findsOneWidget);
      expect(_colorOf(tester, '4'), _colors(tester).alert);
    });
  });

  testWidgets('shows price, cost, margin, description and hidden tag',
      (tester) async {
    await tester.pumpWidget(_wrap(ProductSummaryCard(
      product: _product(active: false, description: 'Seven crochet tulips'),
      cost: 100,
      buildable: 10,
    )));

    expect(find.text(CurrencyFormatter.format(400)), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(100)), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(_colorOf(tester, '75%'), _colors(tester).go);
    expect(find.text('Seven crochet tulips'), findsOneWidget);
    expect(find.text('HIDDEN'), findsOneWidget);
  });

  testWidgets('shows a negative margin in alert colour', (tester) async {
    await tester.pumpWidget(_wrap(
        ProductSummaryCard(product: _product(), cost: 500, buildable: 10)));

    expect(find.text('−25%'), findsOneWidget);
    expect(_colorOf(tester, '−25%'), _colors(tester).alert);
  });

  group('ProductSummaryCard photo', () {
    testWidgets('shows nothing extra without a photo', (tester) async {
      await tester.pumpWidget(_wrap(
          ProductSummaryCard(product: _product(), cost: 100, buildable: 3)));
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows the photo and enlarges it on tap', (tester) async {
      final product = Product(
        id: 1,
        name: 'Tulip bouquet',
        sellPrice: 400,
        isActive: true,
        photo: tinyPng,
        createdAt: _now,
        updatedAt: _now,
      );
      await tester.pumpWidget(
          _wrap(ProductSummaryCard(product: product, cost: 100, buildable: 3)));
      expect(find.byType(Image), findsOneWidget);

      await tester.tap(find.byType(Image));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });
  });
}
