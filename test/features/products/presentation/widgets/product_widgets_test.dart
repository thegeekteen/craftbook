import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/theme/colors.dart';
import 'package:craftbook/core/utils/currency_formatter.dart';
import 'package:craftbook/core/widgets/money_breakdown.dart';
import 'package:craftbook/features/products/domain/entities/channel.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/presentation/widgets/channel_card.dart';
import 'package:craftbook/features/products/presentation/widgets/product_card.dart';
import 'package:craftbook/features/products/presentation/widgets/product_profit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

final _now = DateTime(2026, 1, 1);

Product _product({
  double price = 400,
  bool active = true,
  bool standalone = false,
  int onHand = 0,
  int alertLevel = 0,
}) =>
    Product(
      id: 1,
      name: 'Tulip bouquet',
      sellPrice: price,
      isActive: active,
      isStandalone: standalone,
      quantityOnHand: onHand,
      alertLevel: alertLevel,
      createdAt: _now,
      updatedAt: _now,
    );

Channel _channel({
  double commission = 8,
  double txn = 2,
  double flat = 5,
  double shipping = 40,
  bool active = true,
}) =>
    Channel(
      id: 1,
      name: 'Shopee',
      commissionRate: commission,
      transactionFeeRate: txn,
      flatFee: flat,
      shippingPaidByUs: shipping,
      isActive: active,
      createdAt: _now,
    );

void main() {
  group('ProductCard', () {
    testWidgets('shows name, price, cost, margin and can-build count',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(),
        unitCost: 100,
        available: 12,
        onTap: () => taps++,
      )));
      expect(find.text('Tulip bouquet'), findsOneWidget);
      expect(find.text('₱400'), findsOneWidget);
      expect(find.text('Cost ₱100 · 75% margin'), findsOneWidget);
      expect(find.text('Can build 12'), findsOneWidget);
      expect(find.text('RESELL'), findsNothing);
      expect(find.text('LOW'), findsNothing);
      expect(find.byType(MoneyBreakdownBar), findsOneWidget);
      await tester.tap(find.text('Tulip bouquet'));
      expect(taps, 1);
    });

    testWidgets('margin rounds and handles missing cost', (tester) async {
      await tester
          .pumpWidget(_wrap(ProductCard(product: _product(price: 300))));
      expect(find.text('Cost ₱0 · 100% margin'), findsOneWidget);
      expect(find.textContaining('Can build'), findsNothing);
    });

    testWidgets('negative margin when cost exceeds price', (tester) async {
      await tester.pumpWidget(
          _wrap(ProductCard(product: _product(price: 100), unitCost: 150)));
      expect(find.text('Cost ₱150 · −50% margin'), findsOneWidget);
    });

    testWidgets('few buildable shows LOW', (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(),
        unitCost: 100,
        available: 3,
      )));
      expect(find.text('Can build 3'), findsOneWidget);
      expect(find.text('LOW'), findsOneWidget);
    });

    testWidgets('zero buildable is not tagged LOW', (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(),
        unitCost: 100,
        available: 0,
      )));
      expect(find.text('Can build 0'), findsOneWidget);
      expect(find.text('LOW'), findsNothing);
    });

    testWidgets('standalone shows Resell tag and in-stock count',
        (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(standalone: true, onHand: 7, alertLevel: 2),
        unitCost: 120,
        available: 7,
      )));
      expect(find.text('RESELL'), findsOneWidget);
      expect(find.text('In stock 7'), findsOneWidget);
      expect(find.text('LOW'), findsNothing);
    });

    testWidgets('standalone low stock uses the product alert level',
        (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(standalone: true, onHand: 2, alertLevel: 5),
        unitCost: 120,
        available: 2,
      )));
      expect(find.text('LOW'), findsOneWidget);
    });

    testWidgets('inactive product shows Hidden and is dimmed', (tester) async {
      await tester
          .pumpWidget(_wrap(ProductCard(product: _product(active: false))));
      expect(find.text('HIDDEN'), findsOneWidget);
      final opacity = tester.widget<Opacity>(find
          .ancestor(
            of: find.text('Tulip bouquet'),
            matching: find.byType(Opacity),
          )
          .first);
      expect(opacity.opacity, 0.6);
    });
  });

  group('ChannelCard.recipe', () {
    test('lists every fee and the shipping we pay', () {
      expect(ChannelCard.recipe(_channel()),
          '8% + 2% + ₱5 · you pay ₱40 shipping');
    });

    test('no fees', () {
      expect(
        ChannelCard.recipe(
            _channel(commission: 0, txn: 0, flat: 0, shipping: 0)),
        'No fees',
      );
    });

    test('no fees but shipping', () {
      expect(
        ChannelCard.recipe(
            _channel(commission: 0, txn: 0, flat: 0, shipping: 130)),
        'No fees · you pay ₱130 shipping',
      );
    });

    test('fractional rates keep one decimal', () {
      expect(
        ChannelCard.recipe(
            _channel(commission: 5.5, txn: 0, flat: 0, shipping: 0)),
        '5.5%',
      );
    });

    test('flat fee with centavos keeps them', () {
      expect(
        ChannelCard.recipe(
            _channel(commission: 0, txn: 0, flat: 2.5, shipping: 0)),
        '₱2.50',
      );
    });
  });

  group('ChannelCard', () {
    testWidgets('shows name, recipe, effective rate and what you keep',
        (tester) async {
      await tester.pumpWidget(_wrap(ChannelCard(channel: _channel())));
      expect(find.text('Shopee'), findsOneWidget);
      expect(find.text('On'), findsOneWidget);
      expect(find.text('8% + 2% + ₱5 · you pay ₱40 shipping'), findsOneWidget);
      // fees on ₱500: 40 + 10 + 5 = 55 -> 11%
      expect(find.text('~11%'), findsOneWidget);
      // keep 500 - 55 - 40 = 405
      expect(find.text('On a ₱500 sale you keep ₱405.00'), findsOneWidget);
    });

    testWidgets('switch calls onActiveChanged', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(_wrap(ChannelCard(
        channel: _channel(),
        onActiveChanged: changes.add,
      )));
      await tester.tap(find.byType(Switch));
      expect(changes, [false]);
    });

    testWidgets('inactive channel reads Off and hidden', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(_wrap(ChannelCard(
        channel: _channel(active: false),
        onActiveChanged: changes.add,
      )));
      expect(find.text('Off'), findsOneWidget);
      expect(find.textContaining('Hidden from new orders'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      expect(changes, [true]);
    });

    testWidgets('card tap fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
          _wrap(ChannelCard(channel: _channel(), onTap: () => taps++)));
      await tester.tap(find.text('Shopee'));
      expect(taps, 1);
    });
  });

  group('ProductProfitCard', () {
    testWidgets('shows profit per piece, cost and margin', (tester) async {
      await tester.pumpWidget(_wrap(const ProductProfitCard(
          sellPrice: 400, cost: 100, isStandalone: false)));

      final c = tester.element(find.byType(ProductProfitCard)).colors;
      expect(find.text('PROFIT PER PIECE'), findsOneWidget);
      final profit = find.text(CurrencyFormatter.formatShort(300));
      expect(profit, findsOneWidget);
      expect(tester.widget<Text>(profit).style?.color, c.go);
      expect(find.textContaining('materials · 75% margin'), findsOneWidget);
      expect(find.byType(MoneyBreakdownBar), findsOneWidget);
    });

    testWidgets('shows a loss in alert colour and says cost for resell',
        (tester) async {
      await tester.pumpWidget(_wrap(const ProductProfitCard(
          sellPrice: 100, cost: 150, isStandalone: true)));

      final c = tester.element(find.byType(ProductProfitCard)).colors;
      final loss = find.text(CurrencyFormatter.formatShort(-50));
      expect(loss, findsOneWidget);
      expect(tester.widget<Text>(loss).style?.color, c.alert);
      expect(find.textContaining('cost ·'), findsOneWidget);
    });
  });
}
