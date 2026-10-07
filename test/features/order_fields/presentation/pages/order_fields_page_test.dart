import 'package:craftbook/app.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/domain/repositories/order_field_repository.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/usecases/create_order.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

T _ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Order fields end to end: settings page, order form and order detail.
void main() {
  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await getIt.reset();
      await configureDependencies(
          database: AppDatabase.forTesting(NativeDatabase.memory()));
    });
  }

  Future<void> open(WidgetTester tester, String location) async {
    await tester.pumpWidget(CraftbookApp(initialLocation: location));
    await _settle(tester);
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  }

  Future<int> field(WidgetTester tester, OrderField f) async =>
      (await tester.runAsync(() async =>
          _ok(await getIt<OrderFieldRepository>().createField(f))))!;

  /// An order with [values], plus the channel and product it needs.
  Future<int> order(WidgetTester tester, Map<int, String> values) async =>
      (await tester.runAsync(() async {
        final channel = _ok(await getIt<ChannelRepository>().createChannel(
          name: 'Shopee',
          commissionRate: 0,
          transactionFeeRate: 0,
          flatFee: 0,
          shippingPaidByUs: 0,
        ));
        final db = getIt<AppDatabase>();
        final product = await db
            .into(db.products)
            .insert(ProductsCompanion.insert(name: 'Tulip', sellPrice: 450));
        return _ok(await getIt<CreateOrder>()(
          customerName: 'Maria Santos',
          orderDate: DateTime.now(),
          shipByDate: DateTime.now().add(const Duration(days: 2)),
          channelId: channel,
          totalSales: 450,
          channelFees: 0,
          shippingCost: 0,
          items: [
            OrderItemInput(
                productId: product,
                productName: 'Tulip',
                quantity: 1,
                unitPrice: 450)
          ],
          fieldValues: values,
        ));
      }))!;

  group('settings page', () {
    testWidgets('starts empty and adds a field through the sheet',
        (tester) async {
      await start(tester);
      await open(tester, RouteNames.orderFields);
      expect(find.text('No order fields yet'), findsOneWidget);

      await tester.tap(find.text('Add field'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Name'), 'Ring size');
      await tester.tap(find.text('Number'));
      await tester.pump();
      expect(
          find.text('Numbers drop leading zeros. Use Text for phone numbers.'),
          findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Add field'));
      await _settle(tester);

      expect(find.text('Ring size'), findsWidgets);
      expect(find.text('Number'), findsOneWidget);
      expect(find.text('Not used yet'), findsOneWidget);
      await teardown(tester);
    });

    testWidgets('a choice field needs at least one choice', (tester) async {
      await start(tester);
      await open(tester, RouteNames.orderFields);
      await tester.tap(find.text('Add field'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Name'), 'Wrap');
      await tester.tap(find.text('Choice'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Add field'));
      await tester.pump();
      expect(find.text('Add at least one choice'), findsOneWidget);
      await teardown(tester);
    });

    testWidgets('archives a used field and restores it', (tester) async {
      await start(tester);
      final address = await field(
          tester, const OrderField(name: 'Address', type: OrderFieldType.text));
      await order(tester, {address: 'Cebu'});
      await open(tester, RouteNames.orderFields);

      expect(find.text('Used on 1 order'), findsOneWidget);
      await tester.tap(find.text('Address'));
      await tester.pumpAndSettle();
      expect(
          find.text('Type can’t change once orders use it.'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Archive'));
      await tester.pumpAndSettle();
      expect(find.text('Archive Address?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
      await _settle(tester);

      expect(find.text('ARCHIVED'), findsOneWidget);
      await tester.tap(find.text('Restore'));
      await _settle(tester);
      expect(find.text('ARCHIVED'), findsNothing);
      await teardown(tester);
    });
  });

  group('order form', () {
    testWidgets('asks for active fields, not archived ones', (tester) async {
      await start(tester);
      await field(
          tester, const OrderField(name: 'Address', type: OrderFieldType.text));
      final old = await field(tester,
          const OrderField(name: 'Old note', type: OrderFieldType.text));
      await tester
          .runAsync(() => getIt<OrderFieldRepository>().setArchived(old, true));
      await open(tester, RouteNames.newOrder);

      expect(find.widgetWithText(TextFormField, 'Address'), findsOneWidget);
      expect(find.text('Old note'), findsNothing);
      expect(find.text('Add order fields (address, size…)'), findsNothing);
      await teardown(tester);
    });

    testWidgets('offers to add fields when there are none', (tester) async {
      await start(tester);
      await open(tester, RouteNames.newOrder);
      expect(find.text('Add order fields (address, size…)'), findsOneWidget);
      await teardown(tester);
    });
  });

  group('order detail', () {
    testWidgets('shows values and copies text ones', (tester) async {
      await start(tester);
      final address = await field(
          tester, const OrderField(name: 'Address', type: OrderFieldType.text));
      final event = await field(tester,
          const OrderField(name: 'Event date', type: OrderFieldType.date));
      final id =
          await order(tester, {address: '22 Rizal Ave', event: '2024-03-05'});

      String? copied;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      await open(tester, RouteNames.orderPath(id));
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Event date'), findsOneWidget);
      expect(find.text('Tue, Mar 5, 2024'), findsOneWidget);

      await tester.tap(find.text('22 Rizal Ave'));
      await tester.pump();
      expect(copied, '22 Rizal Ave');
      expect(find.text('Address copied'), findsOneWidget);
      await teardown(tester);
    });
  });
}

/// Lets real database futures finish, then draws frames.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
