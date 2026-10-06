import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_discount.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/app_harness.dart';

/// Paid status end to end: the Orders list filter, the order page, the
/// Waiting for payment list and its Reports card.
void main() {
  late int unpaidId;

  Future<void> seed() async {
    final channel = ok(await getIt<ChannelRepository>().createChannel(
        name: 'Walk-in',
        commissionRate: 0,
        transactionFeeRate: 0,
        flatFee: 0,
        shippingPaidByUs: 0,
        paidByDefault: false));
    final product = ok(await getIt<ProductRepository>()
        .createProduct(name: 'Tulip', sellPrice: 450));
    Future<int> order(String name, {required bool paid}) async =>
        ok(await getIt<OrderRepository>().createOrder(
          customerName: name,
          orderDate: DateTime.now(),
          shipByDate: DateTime.now(),
          channelId: channel,
          totalSales: 450,
          totalMaterialCost: 0,
          channelFees: 0,
          shippingCost: 0,
          profit: 450,
          items: [
            OrderItemInput(
                productId: product,
                productName: 'Tulip',
                quantity: 1,
                unitPrice: 450),
          ],
          materials: const [],
          terms: OrderTerms(isPaid: paid),
        ));
    unpaidId = await order('Ana', paid: false);
    await order('Ben', paid: true);
  }

  testWidgets('the Orders list tags and filters unpaid orders', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.orders);

    expect(find.text('UNPAID'), findsOneWidget);
    await tester.tap(find.byTooltip('Filter'));
    await settle(tester);
    await tester.tap(find.text('Unpaid'));
    await tester.tap(find.text('Show'));
    await settle(tester);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Ben'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('marking an order paid from its page', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.orderPath(unpaidId));

    expect(find.text('Waiting for payment'), findsOneWidget);
    await tester.ensureVisible(find.text('Mark paid'));
    await tester.tap(find.text('Mark paid'));
    await settle(tester);

    final Result<Order?> result = await db<Result<Order?>>(
        tester, () => getIt<OrderRepository>().getOrderById(unpaidId));
    expect((result as Success<Order?>).value!.isPaid, isTrue);
    expect(find.textContaining('Paid '), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('Waiting for payment groups what is owed', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.receivables);

    expect(find.text('OWED TO YOU · 1 ORDER'), findsOneWidget);
    expect(find.text('ANA · ₱450'), findsOneWidget);
    expect(find.text('Ben'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('Reports links to what is owed', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.reports);

    expect(find.text('Waiting for payment'), findsOneWidget);
    await tester.tap(find.text('Waiting for payment'));
    await settle(tester);
    expect(find.text('ANA · ₱450'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('More shows what is owed, tax and discounts', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.settings);

    expect(find.text('₱450.00 · 1 order'), findsOneWidget);
    expect(find.text('Tax'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
    expect(find.text('Discounts'), findsOneWidget);
    await closeApp(tester);
  });
}
