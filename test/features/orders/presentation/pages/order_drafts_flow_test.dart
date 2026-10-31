import 'package:craftbook/app.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart' show AppDatabase;
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/save_draft_order.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The two journeys the feature exists for, on a shop with nothing set up:
/// backing out of an order without losing it, and making the product (and
/// its material) from inside the order.
void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies(
        database: AppDatabase.forTesting(NativeDatabase.memory()));
    await getIt<ChannelRepository>().createChannel(
        name: 'Facebook',
        commissionRate: 0,
        transactionFeeRate: 0,
        flatFee: 0,
        shippingPaidByUs: 0);
  });

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  }

  Future<List<Order>> allOrders(WidgetTester tester) async {
    final result =
        await tester.runAsync(() => getIt<OrderRepository>().getAllOrders());
    return (result as Success<List<Order>>).value;
  }

  Future<void> openNewOrder(WidgetTester tester) async {
    await tester.pumpWidget(CraftbookApp(initialLocation: RouteNames.orders));
    await _settle(tester);
    // Through the button, so Orders reloads when the wizard closes.
    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);
  }

  testWidgets(
      'backing out keeps the order as a draft, and it reopens where '
      'it stopped', (tester) async {
    await openNewOrder(tester);
    await tester.enterText(_field('Customer name'), 'Ana Reyes');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close_rounded));
    await _settle(tester);
    expect(find.text('Keep this order for later?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Save draft'));
    await _settle(tester);

    final saved = await allOrders(tester);
    expect(saved.single.status, OrderStatus.draft);
    expect(saved.single.customerName, 'Ana Reyes');
    expect(find.text('Draft saved'), findsOneWidget);

    await tester.tap(find.text('Drafts'));
    await _settle(tester);
    expect(find.text('Ana Reyes'), findsOneWidget);
    expect(find.text('Needs: items'), findsOneWidget);

    // Name and channel are there, so it opens on the items step.
    await tester.tap(find.text('Ana Reyes'));
    await _settle(tester);
    expect(find.text('Draft #${saved.single.id}'), findsOneWidget);
    expect(find.text('No items yet'), findsOneWidget);

    expect(tester.takeException(), isNull);
    await close(tester);
  });

  testWidgets('an empty form closes without asking', (tester) async {
    await openNewOrder(tester);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await _settle(tester);
    expect(find.text('Keep this order for later?'), findsNothing);
    expect(await allOrders(tester), isEmpty);
    await close(tester);
  });

  testWidgets('a draft can only be continued or deleted', (tester) async {
    await tester.runAsync(() => getIt<SaveDraftOrder>()(
        customerName: 'Ana Reyes',
        orderDate: DateTime.now(),
        shipByDate: DateTime.now()));
    await tester.pumpWidget(CraftbookApp(initialLocation: RouteNames.orders));
    await _settle(tester);
    await tester.tap(find.text('Drafts'));
    await _settle(tester);

    await tester.longPress(find.text('Ana Reyes'));
    await _settle(tester);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Delete order'), findsOneWidget);
    expect(find.text('Cancel order'), findsNothing);
    expect(find.text('Mark paid'), findsNothing);
    expect(find.text('Mark unpaid'), findsNothing);

    await tester.tap(find.text('Delete order'));
    await _settle(tester);
    expect(find.text('Delete this draft?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await _settle(tester);
    expect(await allOrders(tester), isEmpty);
    expect(find.text('No orders yet'), findsOneWidget);
    await close(tester);
  });

  testWidgets('a product and its material are made from inside the order',
      (tester) async {
    await openNewOrder(tester);
    await tester.enterText(_field('Customer name'), 'Ana Reyes');
    await tester.tap(find.text('Next: add items'));
    await _settle(tester);

    // No products yet: the picker offers to make one.
    await tester.tap(find.text('Add product').last);
    await _settle(tester);
    await tester.tap(find.text('New product').last);
    await _settle(tester);
    expect(find.text('Saving adds it to the order you’re making.'),
        findsOneWidget);
    await tester.enterText(_field('Name'), 'Birthday card');
    await tester.enterText(_field('Sell price'), '120');
    await tester.pump();

    // No materials yet either: the materials sheet makes one too.
    final addMaterial = find.textContaining('Add what this is made from');
    await tester.scrollUntilVisible(addMaterial, 200,
        scrollable: find
            .ancestor(of: _field('Name'), matching: find.byType(Scrollable))
            .last);
    await tester.tap(addMaterial);
    await _settle(tester);
    await tester.tap(find.text('New material').last);
    await _settle(tester);
    expect(find.text('Saving adds it to the product’s materials.'),
        findsOneWidget);
    await tester.enterText(_field('Name'), 'Kraft cardstock');
    await tester.enterText(_field('per pack'), '10');
    await tester.enterText(_field('Pack price'), '180');
    await tester.tap(find.widgetWithText(FilledButton, 'Add material'));
    await _settle(tester);

    expect(find.text('Kraft cardstock'), findsOneWidget,
        reason: 'the new material did not land on the product');
    await tester.tap(find.widgetWithText(FilledButton, 'Add product'));
    await _settle(tester);

    expect(find.text('Birthday card'), findsOneWidget,
        reason: 'the new product did not land on the order');

    // The new material starts at nothing, so Review offers to receive it.
    await tester.tap(find.text('Review'));
    await _settle(tester);
    final receive = find.widgetWithText(TextButton, 'Receive');
    await tester.scrollUntilVisible(receive, 200,
        scrollable: find.byType(Scrollable).last);
    expect(receive, findsOneWidget);
    expect(tester.takeException(), isNull);
    await close(tester);
  });
}

/// A text field by (part of) its label.
Finder _field(String label) => find.byWidgetPredicate((w) =>
    w is TextField && (w.decoration?.labelText?.contains(label) ?? false));

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
