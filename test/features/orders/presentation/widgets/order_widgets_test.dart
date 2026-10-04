import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/utils/date_utils.dart' as app_date;
import 'package:craftbook/core/widgets/app_tag.dart';
import 'package:craftbook/core/widgets/inline_banner.dart';
import 'package:craftbook/core/widgets/pip_strip.dart';
import 'package:craftbook/core/widgets/status_pill.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_list_entry.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/entities/order_product.dart';
import 'package:craftbook/features/orders/presentation/bloc/order_detail_state.dart';
import 'package:craftbook/features/orders/presentation/widgets/order_card.dart';
import 'package:craftbook/features/orders/presentation/widgets/order_mini_row.dart';
import 'package:craftbook/features/orders/presentation/widgets/order_status_ui.dart';
import 'package:craftbook/features/orders/presentation/widgets/pack_confirm_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

DateTime _day(int offset) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + offset);
}

Order _order({
  int? id = 42,
  OrderStatus status = OrderStatus.pending,
  int shipInDays = 3,
  DateTime? shippedAt,
  double sales = 500,
  double materials = 100,
  double fees = 50,
  double shipping = 40,
  double profit = 999, // deliberately stale
}) {
  final now = DateTime.now();
  return Order(
    id: id,
    customerName: 'Maria Santos',
    orderDate: _day(-1),
    shipByDate: _day(shipInDays),
    shippedAt: shippedAt,
    status: status,
    totalSales: sales,
    totalMaterialCost: materials,
    channelFees: fees,
    shippingCost: shipping,
    profit: profit,
    createdAt: now,
    updatedAt: now,
  );
}

OrderListEntry _entry(Order order, {String? channel = 'Shopee'}) => OrderListEntry(
      order: order,
      channelName: channel,
      lines: const [
        OrderLine(productName: 'Tulip bouquet', quantity: 2),
        OrderLine(productName: 'Gift box', quantity: 1),
      ],
    );

void main() {
  group('OrderStatusLabel', () {
    test('labels', () {
      expect(OrderStatus.pending.label, 'To pack');
      expect(OrderStatus.packed.label, 'Packed');
      expect(OrderStatus.shipped.label, 'Shipped');
      expect(OrderStatus.cancelled.label, 'Cancelled');
    });
  });

  group('OrderUi', () {
    test('isOverdue only for pending orders past their ship-by day', () {
      expect(_order(shipInDays: -1).isOverdue, isTrue);
      expect(_order(shipInDays: -10).isOverdue, isTrue);
      expect(_order(shipInDays: 0).isOverdue, isFalse);
      expect(_order(shipInDays: 2).isOverdue, isFalse);
      expect(_order(shipInDays: -1, status: OrderStatus.packed).isOverdue, isFalse);
      expect(_order(shipInDays: -1, status: OrderStatus.shipped).isOverdue, isFalse);
      expect(_order(shipInDays: -1, status: OrderStatus.cancelled).isOverdue, isFalse);
    });

    test('isOverdue ignores time of day on today', () {
      final now = DateTime.now();
      final earlyToday = _order().copyWith(
        shipByDate: DateTime(now.year, now.month, now.day, 0, 1),
      );
      expect(earlyToday.isOverdue, isFalse);
    });

    test('liveProfit is computed from components, not stored profit', () {
      final o = _order(sales: 500, materials: 100, fees: 50, shipping: 40, profit: 999);
      expect(o.liveProfit, 310);
    });

    test('liveProfit can be negative', () {
      expect(_order(sales: 100, materials: 150, fees: 0, shipping: 0).liveProfit, -50);
    });
  });

  group('OrderStatusPill', () {
    testWidgets('shows a pill per status', (tester) async {
      await tester.pumpWidget(_wrap(const Column(children: [
        OrderStatusPill(status: OrderStatus.pending),
        OrderStatusPill(status: OrderStatus.packed),
        OrderStatusPill(status: OrderStatus.shipped),
        OrderStatusPill(status: OrderStatus.cancelled),
      ])));
      expect(find.text('TO PACK'), findsOneWidget);
      expect(find.text('PACKED'), findsOneWidget);
      expect(find.text('SHIPPED'), findsOneWidget);
      expect(find.text('CANCELLED'), findsOneWidget);
    });

    testWidgets('overdue pending order shows OVERDUE', (tester) async {
      await tester.pumpWidget(_wrap(OrderStatusPill.of(_order(shipInDays: -2))));
      expect(find.text('OVERDUE'), findsOneWidget);
      expect(tester.widget<StatusPill>(find.byType(StatusPill)).type, StatusPillType.alert);
    });

    testWidgets('overdue flag is ignored for non-pending orders', (tester) async {
      await tester.pumpWidget(_wrap(const OrderStatusPill(
        status: OrderStatus.packed,
        overdue: true,
      )));
      expect(find.text('PACKED'), findsOneWidget);
      expect(find.text('OVERDUE'), findsNothing);
    });

    testWidgets('pending on time shows TO PACK', (tester) async {
      await tester.pumpWidget(_wrap(OrderStatusPill.of(_order(shipInDays: 1))));
      expect(find.text('TO PACK'), findsOneWidget);
    });
  });

  group('orderStatusColor', () {
    test('maps overdue and statuses to colours', () {
      Color colorOf(Order o) => orderStatusColor(o,
          alert: Colors.red,
          warn: Colors.amber,
          go: Colors.green,
          coin: Colors.blue,
          muted: Colors.grey);
      expect(colorOf(_order(shipInDays: -1)), Colors.red);
      expect(colorOf(_order()), Colors.amber);
      expect(colorOf(_order(status: OrderStatus.packed)), Colors.green);
      expect(colorOf(_order(status: OrderStatus.shipped)), Colors.blue);
      expect(colorOf(_order(status: OrderStatus.cancelled)), Colors.grey);
    });
  });

  group('OrderCard', () {
    testWidgets('renders customer, items, id, channel and live profit', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(OrderCard(
        entry: _entry(_order()),
        onTap: () => taps++,
      )));
      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('2× Tulip bouquet · 1× Gift box'), findsOneWidget);
      expect(find.text('#42'), findsOneWidget);
      expect(find.text('Shopee'), findsOneWidget);
      expect(tester.widget<AppTag>(find.byType(AppTag)).type, AppTagType.outline);
      expect(find.text('TO PACK'), findsOneWidget);
      // 500 - 100 - 50 - 40, never the stale stored 999
      expect(find.text('₱310'), findsOneWidget);
      expect(find.text('₱999'), findsNothing);
      await tester.tap(find.text('Maria Santos'));
      expect(taps, 1);
    });

    testWidgets('negative profit shows the formatted loss', (tester) async {
      await tester.pumpWidget(_wrap(OrderCard(
        entry: _entry(_order(sales: 100, materials: 150, fees: 0, shipping: 0, profit: 50)),
      )));
      // Formatted with NumberFormat's ASCII hyphen, unlike CurrencyText's '−'.
      expect(find.text('−₱50'), findsOneWidget);
      expect(find.text('₱50'), findsNothing);
    });

    testWidgets('hides channel and items when absent', (tester) async {
      await tester.pumpWidget(_wrap(OrderCard(
        entry: OrderListEntry(order: _order()),
      )));
      expect(find.byType(AppTag), findsNothing);
      expect(find.textContaining('×'), findsNothing);
    });

    testWidgets('cancelled orders hide profit', (tester) async {
      await tester.pumpWidget(_wrap(OrderCard(
        entry: _entry(_order(status: OrderStatus.cancelled)),
      )));
      expect(find.text('₱310'), findsNothing);
      expect(find.text('CANCELLED'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('unsaved order shows a dash for id', (tester) async {
      await tester.pumpWidget(_wrap(OrderCard(entry: _entry(_order(id: null)))));
      expect(find.text('#–'), findsOneWidget);
    });

    testWidgets('overdue order shows OVERDUE and due text', (tester) async {
      await tester.pumpWidget(_wrap(OrderCard(entry: _entry(_order(shipInDays: -3)))));
      expect(find.text('OVERDUE'), findsOneWidget);
      expect(find.text('Due 3 days ago'), findsOneWidget);
    });
  });

  group('OrderCard.whenLabel', () {
    test('overdue pending orders are urgent', () {
      expect(OrderCard.whenLabel(_order(shipInDays: -1)), ('Due yesterday', true));
      expect(OrderCard.whenLabel(_order(shipInDays: -4)), ('Due 4 days ago', true));
    });

    test('ships today is urgent only while pending', () {
      expect(OrderCard.whenLabel(_order(shipInDays: 0)), ('Ships today', true));
      expect(
        OrderCard.whenLabel(_order(shipInDays: 0, status: OrderStatus.packed)),
        ('Ships today', false),
      );
    });

    test('packed orders past ship-by are not shown as due', () {
      final (text, urgent) =
          OrderCard.whenLabel(_order(shipInDays: -2, status: OrderStatus.packed));
      expect(text, 'Ships ${app_date.DateUtils.friendly(_day(-2))}');
      expect(urgent, isFalse);
    });

    test('future orders show the friendly date', () {
      expect(OrderCard.whenLabel(_order(shipInDays: 1)), ('Ships Tomorrow', false));
      expect(
        OrderCard.whenLabel(_order(shipInDays: 5)),
        ('Ships ${app_date.DateUtils.friendly(_day(5))}', false),
      );
    });

    test('shipped orders show when they shipped', () {
      expect(
        OrderCard.whenLabel(_order(status: OrderStatus.shipped, shippedAt: _day(-1))),
        ('Shipped Yesterday', false),
      );
      expect(
        OrderCard.whenLabel(_order(status: OrderStatus.shipped)),
        ('Shipped', false),
      );
    });

    test('cancelled orders', () {
      expect(
        OrderCard.whenLabel(_order(status: OrderStatus.cancelled, shipInDays: -5)),
        ('Cancelled', false),
      );
    });
  });

  group('OrderMiniRow', () {
    testWidgets('shows name, id, piece count, live profit and pill', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(OrderMiniRow(
        entry: _entry(_order(status: OrderStatus.packed)),
        onTap: () => taps++,
      )));
      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('#42 · 3 items · ₱310 profit'), findsOneWidget);
      expect(find.text('PACKED'), findsOneWidget);
      await tester.tap(find.text('Maria Santos'));
      expect(taps, 1);
    });

    testWidgets('singular item and no lines', (tester) async {
      await tester.pumpWidget(_wrap(OrderMiniRow(
        entry: OrderListEntry(
          order: _order(),
          lines: const [OrderLine(productName: 'Tulip', quantity: 1)],
        ),
      )));
      expect(find.text('#42 · 1 item · ₱310 profit'), findsOneWidget);
    });

    testWidgets('cancelled hides profit; no lines hides count', (tester) async {
      await tester.pumpWidget(_wrap(OrderMiniRow(
        entry: OrderListEntry(order: _order(status: OrderStatus.cancelled)),
      )));
      expect(find.text('#42'), findsOneWidget);
    });
  });

  group('PackLine', () {
    test('before/after from stock', () {
      const line = PackLine(
        name: 'Beads',
        quantity: 4,
        stock: StockLevel(onHand: 10, alertLevel: 3),
      );
      expect(line.before, 10);
      expect(line.after, 6);
      expect(line.isShort, isFalse);
      expect(line.endsLow, isFalse);
    });

    test('ends low at or below alert level', () {
      const line = PackLine(
        name: 'Beads',
        quantity: 7,
        stock: StockLevel(onHand: 10, alertLevel: 3),
      );
      expect(line.after, 3);
      expect(line.endsLow, isTrue);
      expect(line.isShort, isFalse);
    });

    test('short when quantity exceeds stock; after clamps to zero', () {
      const line = PackLine(
        name: 'Wire',
        quantity: 8,
        stock: StockLevel(onHand: 3, alertLevel: 1),
      );
      expect(line.isShort, isTrue);
      expect(line.after, 0);
      expect(line.endsLow, isTrue);
    });

    test('exact stock is not short', () {
      const line = PackLine(
        name: 'Wire',
        quantity: 3,
        stock: StockLevel(onHand: 3, alertLevel: 0),
      );
      expect(line.isShort, isFalse);
      expect(line.after, 0);
    });

    test('unknown stock is neither short nor low', () {
      const line = PackLine(name: 'Ribbon', quantity: 2);
      expect(line.before, 0);
      expect(line.after, 0);
      expect(line.isShort, isFalse);
      expect(line.endsLow, isFalse);
    });
  });

  group('PackConfirmSheet', () {
    testWidgets('shows lines with before/after, LOW tag and pips', (tester) async {
      await tester.pumpWidget(_wrap(const PackConfirmSheet(lines: [
        PackLine(name: 'Beads', quantity: 4, stock: StockLevel(onHand: 10, alertLevel: 3)),
        PackLine(name: 'Clasp', quantity: 2, stock: StockLevel(onHand: 4, alertLevel: 2)),
        PackLine(name: 'Ribbon', quantity: 2),
      ])));
      expect(find.text('Pack this order?'), findsOneWidget);
      expect(find.text('These pieces come off your shelf.'), findsOneWidget);
      expect(find.text('Beads'), findsOneWidget);
      expect(find.text('10 → 6'), findsOneWidget);
      expect(find.text('4 → 2'), findsOneWidget);
      expect(find.text('−2'), findsOneWidget);
      expect(find.text('LOW'), findsOneWidget); // only Clasp ends low
      expect(find.byType(PipStrip), findsNWidgets(2));
      expect(find.byType(InlineBanner), findsNothing);
    });

    testWidgets('warns about short lines', (tester) async {
      await tester.pumpWidget(_wrap(const PackConfirmSheet(lines: [
        PackLine(name: 'Wire', quantity: 8, stock: StockLevel(onHand: 3, alertLevel: 1)),
      ])));
      expect(find.text('3 → 0'), findsOneWidget);
      expect(find.text('Short on Wire. Stock will stop at 0.'), findsOneWidget);
    });

    testWidgets('empty sheet says nothing to take', (tester) async {
      await tester.pumpWidget(_wrap(const PackConfirmSheet(lines: [])));
      expect(find.text('Nothing to take from stock for this order.'), findsOneWidget);
    });

    Future<List<bool>> pumpLauncher(WidgetTester tester) async {
      final results = <bool>[];
      final now = DateTime.now();
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            results.add(await PackConfirmSheet.show(
              context,
              materials: [
                OrderMaterial(
                  orderId: 1,
                  materialId: 7,
                  materialName: 'Beads',
                  plannedQuantity: 4,
                  actualQuantity: 5,
                  wasteQuantity: 1,
                  unitCost: 2,
                  createdAt: now,
                ),
              ],
              products: const [
                OrderProduct(
                  orderId: 1,
                  productId: 3,
                  productName: 'Keychain',
                  quantity: 2,
                  unitCost: 30,
                ),
              ],
              materialStock: const {7: StockLevel(onHand: 10, alertLevel: 2)},
              productStock: const {3: StockLevel(onHand: 6, alertLevel: 1)},
            ));
          },
          child: const Text('Open'),
        ),
      )));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('show builds lines and returns true on Pack & deduct', (tester) async {
      final results = await pumpLauncher(tester);
      expect(find.byType(PackConfirmSheet), findsOneWidget);
      // actual quantity (with waste) is used, not planned
      expect(find.text('10 → 5'), findsOneWidget);
      expect(find.text('Keychain'), findsOneWidget);
      expect(find.text('6 → 4'), findsOneWidget);
      await tester.tap(find.text('Pack & deduct'));
      await tester.pumpAndSettle();
      expect(results, [true]);
      expect(find.byType(PackConfirmSheet), findsNothing);
    });

    testWidgets('show returns false on Cancel', (tester) async {
      final results = await pumpLauncher(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(results, [false]);
    });
  });
}
