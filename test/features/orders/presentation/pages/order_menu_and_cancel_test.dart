import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/widgets/choice_chip_row.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/cancel_order.dart';
import 'package:craftbook/features/orders/domain/usecases/create_order.dart';
import 'package:craftbook/features/orders/domain/usecases/pack_order.dart';
import 'package:craftbook/features/orders/domain/usecases/ship_order.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/app_harness.dart';

/// The order long-press menu and cancelling, end to end.
void main() {
  late int beads;
  late int ana; // pending, 1 bracelet → 2 beads promised
  late int ben; // packed, 1 bracelet → 2 beads used
  late int cy; // shipped
  late int dee; // cancelled

  /// 10 beads; a bracelet takes 2. Ana's order reserves 2; Ben's packed
  /// and Cy's shipped orders used 2 each, so 6 on hand with 2 promised.
  Future<void> seed() async {
    final materials = getIt<MaterialRepository>();
    final products = getIt<ProductRepository>();
    beads = ok(await materials.createMaterial(
      name: 'Beads',
      packSize: 10,
      packPrice: 50,
      unitCost: 5,
      quantityOnHand: 10,
      alertLevel: 0,
    ));
    final bracelet =
        ok(await products.createProduct(name: 'Bracelet', sellPrice: 200));
    ok(await products.saveBomItems(
        bracelet, [BomItemInput(materialId: beads, quantityRequired: 2)]));
    final walkIn = ok(await getIt<ChannelRepository>().createChannel(
        name: 'Walk-in',
        commissionRate: 0,
        transactionFeeRate: 0,
        flatFee: 0,
        shippingPaidByUs: 0));
    final today = DateTime.now();
    Future<int> order(String customer) async => ok(await getIt<CreateOrder>()(
          customerName: customer,
          orderDate: today,
          shipByDate: today.add(const Duration(days: 3)),
          channelId: walkIn,
          totalSales: 200,
          channelFees: 0,
          shippingCost: 0,
          items: [
            OrderItemInput(
                productId: bracelet,
                productName: 'Bracelet',
                quantity: 1,
                unitPrice: 200),
          ],
        ));
    ana = await order('Ana');
    ben = await order('Ben');
    ok(await getIt<PackOrder>()(ben));
    cy = await order('Cy');
    ok(await getIt<PackOrder>()(cy));
    ok(await getIt<ShipOrder>()(cy));
    dee = await order('Dee');
    ok(await getIt<CancelOrder>()(dee));
  }

  Future<Material> stock(WidgetTester tester) async {
    final r = await db<Result<Material?>>(
        tester, () => getIt<MaterialRepository>().getMaterialById(beads));
    // A typed local: inferring ok's T from the async return type breaks.
    final Material? m = ok(r);
    return m!;
  }

  Future<OrderStatus?> status(WidgetTester tester, int id) async {
    final r = await db<Result<Order?>>(
        tester, () => getIt<OrderRepository>().getOrderById(id));
    final Order? o = ok(r);
    return o?.status;
  }

  /// Orders opens on To pack; most tests want every order.
  Future<void> openAll(WidgetTester tester) async {
    await openApp(tester, RouteNames.orders);
    final chip = find.widgetWithText(AppChip, 'All');
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await settle(tester);
  }

  Future<void> longPress(WidgetTester tester, String customer) async {
    final card = find.text(customer);
    await tester.ensureVisible(card);
    await tester.longPress(card);
    await settle(tester);
  }

  testWidgets('seed: cancelling Dee gave back her reservation', (t) async {
    await startApp(t, seed: seed);
    final m = await stock(t);
    expect((m.quantityOnHand, m.quantityPromised), (6, 2));
    await closeApp(t);
  });

  testWidgets('long press cancels a pending order and frees its stock',
      (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.orders);
    await longPress(tester, 'Ana');

    expect(find.text('Edit order'), findsOneWidget);
    expect(find.text('Delete order'), findsOneWidget);
    expect(find.text('Mark shipped'), findsNothing);
    await tester.tap(find.text('Cancel order'));
    await settle(tester);
    expect(find.text('Cancel order #$ana?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Cancel order'));
    await settle(tester);

    expect(await status(tester, ana), OrderStatus.cancelled);
    final m = await stock(tester);
    expect((m.quantityOnHand, m.quantityPromised), (6, 0));
    expect(find.text('Order cancelled. Stock returned.'), findsOneWidget);
    // Gone from To pack once the list reloads.
    expect(find.text('Ana'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('Keep order backs out without touching anything', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.orders);
    await longPress(tester, 'Ana');
    await tester.tap(find.text('Cancel order'));
    await settle(tester);
    await tester.tap(find.text('Keep order'));
    await settle(tester);

    expect(await status(tester, ana), OrderStatus.pending);
    expect((await stock(tester)).quantityPromised, 2);
    await closeApp(tester);
  });

  testWidgets('a packed order can be marked shipped from the list',
      (tester) async {
    await startApp(tester, seed: seed);
    await openAll(tester);
    await longPress(tester, 'Ben');
    await tester.tap(find.text('Mark shipped'));
    await settle(tester);

    expect(await status(tester, ben), OrderStatus.shipped);
    expect(find.text('Marked as shipped'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('shipped orders only offer the note', (tester) async {
    await startApp(tester, seed: seed);
    await openAll(tester);
    await longPress(tester, 'Cy');

    expect(find.text('Edit note'), findsOneWidget);
    expect(find.text('Cancel order'), findsNothing);
    expect(find.text('Delete order'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('a cancelled order can only be deleted, and stock stays put',
      (tester) async {
    await startApp(tester, seed: seed);
    await openAll(tester);
    await longPress(tester, 'Dee');

    expect(find.text('Edit order'), findsNothing);
    expect(find.text('Cancel order'), findsNothing);
    await tester.tap(find.text('Delete order'));
    await settle(tester);
    expect(
        find.text('The cancelled order is removed for good.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    expect(await status(tester, dee), isNull);
    final m = await stock(tester);
    expect((m.quantityOnHand, m.quantityPromised), (6, 2));
    await closeApp(tester);
  });

  testWidgets('the detail menu cancels a packed order and restocks it',
      (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.orderPath(ben));
    await tester.tap(find.byTooltip('More'));
    await settle(tester);
    await tester.tap(find.text('Cancel order'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Cancel order'));
    await settle(tester);

    expect(await status(tester, ben), OrderStatus.cancelled);
    final m = await stock(tester);
    expect((m.quantityOnHand, m.quantityPromised), (8, 2));
    // No more Mark shipped once it's cancelled.
    expect(find.text('Mark shipped'), findsNothing);
    await closeApp(tester);
  });
}
