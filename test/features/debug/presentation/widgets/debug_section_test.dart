import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/factory/fake_shop_generator.dart';
import 'package:craftbook/features/debug/presentation/bloc/debug_cubit.dart';
import 'package:craftbook/features/debug/presentation/widgets/debug_section.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/app_harness.dart';
import '../../../../support/localized_app.dart';

void main() {
  Future<List<Order>> orders() async =>
      ok(await getIt<OrderRepository>().getAllOrders());

  /// The Debug group as the More page mounts it, over a real empty database.
  Future<void> openSection(WidgetTester tester) async {
    await startApp(tester);
    await tester.pumpWidget(localizedApp(
      Scaffold(
        body: BlocProvider(
          create: (_) => getIt<DebugCubit>(),
          child: const DebugSection(),
        ),
      ),
    ));
    await settle(tester);
  }

  /// The seed runs a whole shop through the app's own write path — about a
  /// second of real work outside the fake clock — so wait on the result rather
  /// than a fixed number of frames.
  Future<void> waitWhileSeeding(WidgetTester tester) async {
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      if (find.textContaining('Building the shop').evaluate().isEmpty) return;
    }
    throw StateError('the seed never finished');
  }

  group('DebugSection', () {
    testWidgets('lists the three debug rows', (tester) async {
      await openSection(tester);

      expect(find.text('Seed fake data'), findsOneWidget);
      expect(find.text('Clear all data'), findsOneWidget);
      expect(find.text('Database & coverage'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('canceling the confirmation seeds nothing', (tester) async {
      await openSection(tester);

      await tester.tap(find.text('Seed fake data'));
      await settle(tester);
      expect(
          find.text('Replace everything with a sample shop?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await settle(tester);

      expect(find.text('Replace everything with a sample shop?'), findsNothing);
      expect(await db<List<Order>>(tester, orders), isEmpty);
      await closeApp(tester);
    });

    testWidgets('confirming builds a sample shop and asks for a restart',
        (tester) async {
      await openSection(tester);

      await tester.tap(find.text('Seed fake data'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Seed it'));
      await waitWhileSeeding(tester);
      await settle(tester);

      expect((await db<List<Order>>(tester, orders)).length, greaterThan(20));
      // Nothing restarts the app inside a widget test, so the message that
      // would have gone to the fresh app has to come out as a snackbar.
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Seeded a sample shop'), findsOneWidget);
      expect(find.textContaining('Restart the app to see it'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('long-pressing the row offers another shop', (tester) async {
      await openSection(tester);

      await tester.longPress(find.text('Seed fake data'));
      await settle(tester);

      expect(find.text('Another shop'), findsOneWidget);
      expect(find.text('Seed'), findsOneWidget);
      expect(find.text('empty for the standard shop'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await closeApp(tester);
    });

    // The dialog used to crash on close (a caller-owned controller disposed
    // while the field was still animating out), so seeding from it never ran.
    testWidgets('long-pressing, typing a seed and confirming builds a shop',
        (tester) async {
      await openSection(tester);

      await tester.longPress(find.text('Seed fake data'));
      await settle(tester);
      await tester.enterText(find.byType(TextField), '777');
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Seed it'));
      await waitWhileSeeding(tester);
      await settle(tester);

      expect((await db<List<Order>>(tester, orders)).length, greaterThan(20));
      expect(find.textContaining('seed 777'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('leaving the typed seed blank builds the standard shop',
        (tester) async {
      await openSection(tester);

      await tester.longPress(find.text('Seed fake data'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Seed it'));
      await waitWhileSeeding(tester);
      await settle(tester);

      expect((await db<List<Order>>(tester, orders)).length, greaterThan(20));
      expect(find.textContaining('seed ${FakeShopGenerator.standardSeed}'),
          findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('a non-number seed warns and writes nothing', (tester) async {
      await openSection(tester);

      await tester.longPress(find.text('Seed fake data'));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'abc');
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Seed it'));
      await settle(tester);

      expect(find.textContaining('is not a whole number'), findsOneWidget);
      expect(await db<List<Order>>(tester, orders), isEmpty);
      await closeApp(tester);
    });

    testWidgets('canceling the another-shop dialog seeds nothing',
        (tester) async {
      await openSection(tester);

      await tester.longPress(find.text('Seed fake data'));
      await settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await settle(tester);

      expect(find.text('Another shop'), findsNothing);
      expect(await db<List<Order>>(tester, orders), isEmpty);
      await closeApp(tester);
    });
  });
}
