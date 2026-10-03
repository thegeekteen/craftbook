@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:craftbook/app.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/sample_data.dart';
import '../support/sqlite.dart';

/// Renders the real app, against an in-memory database seeded with a sample
/// shop, and saves each screen as a PNG under goldens/.
void main() {
  setUpAll(() async {
    useHostSqlite();
    await _loadFonts();
  });

  final now = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  final weekEnd = DateTime(weekStart.year, weekStart.month, weekStart.day + 6, 23, 59, 59);

  final screens = <(String, String)>[
    ('today', RouteNames.today),
    ('orders', RouteNames.orders),
    ('new_order', RouteNames.newOrder),
    ('order_overdue', RouteNames.orderPath(8)),
    ('order_packed', RouteNames.orderPath(10)),
    ('order_shipped', RouteNames.orderPath(4)),
    ('calendar_week', RouteNames.calendarWeek),
    ('calendar_month', RouteNames.calendarMonth),
    ('stock', RouteNames.materials),
    ('material_detail', RouteNames.materialPath(1)),
    ('receive_stock', RouteNames.receiveStockPath(1)),
    ('new_material', RouteNames.newMaterial),
    ('buy_list', RouteNames.buyList),
    ('products', RouteNames.products),
    ('product_editor', RouteNames.productEditorPath(1)),
    ('product_resell', RouteNames.productEditorPath(4)),
    ('channels', RouteNames.channels),
    ('money', RouteNames.earnings),
    ('product_earnings', RouteNames.productEarningsPath(1, weekStart.subtract(const Duration(days: 28)), weekEnd)),
    ('more', RouteNames.settings),
  ];

  for (final (name, route) in screens) {
    for (final dark in [false, true]) {
      testWidgets('$name ${dark ? 'dark' : 'light'}', (tester) async {
        await _boot(tester, route, dark);
        await expectLater(
          find.byType(CraftbookApp),
          matchesGoldenFile('goldens/${name}_${dark ? 'dark' : 'light'}.png'),
        );
        await _teardown(tester);
      });
    }
  }

  testWidgets('pack sheet', (tester) async {
    await _boot(tester, RouteNames.orderPath(8), false);
    await tester.tap(find.text('Pack order'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp), matchesGoldenFile('goldens/pack_sheet_light.png'));
    await _teardown(tester);
  });

  testWidgets('new order review', (tester) async {
    await _boot(tester, RouteNames.newOrder, false);
    await tester.enterText(find.byType(TextFormField).first, 'Rina Velasco');
    await tester.tap(find.text('Next: add items'));
    await _settle(tester);
    await tester.tap(find.text('Add product').first);
    await _settle(tester);
    await tester.tap(find.text('Crochet tulip bouquet'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp), matchesGoldenFile('goldens/new_order_items_light.png'));
    await tester.tap(find.text('Review'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp), matchesGoldenFile('goldens/new_order_review_light.png'));
    await _teardown(tester);
  });
}

Future<void> _boot(WidgetTester tester, String route, bool dark) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  // Draw real shadows instead of the test framework's outline stand-ins.
  debugDisableShadows = false;
  await tester.runAsync(() async {
    await getIt.reset();
    await configureDependencies(database: AppDatabase.forTesting(NativeDatabase.memory()));
    await seedSampleShop();
  });
  await tester.pumpWidget(CraftbookApp(
    initialLocation: route,
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  ));
  await _settle(tester);
}

/// Lets real database futures finish, then draws frames.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(() => getIt<AppDatabase>().close());
  debugDisableShadows = true;
}

Future<void> _loadFonts() async {
  const families = {
    'Bricolage': ['BricolageGrotesque-Medium', 'BricolageGrotesque-SemiBold', 'BricolageGrotesque-Bold'],
    'IBMPlexSans': ['IBMPlexSans-Regular', 'IBMPlexSans-Medium', 'IBMPlexSans-SemiBold', 'IBMPlexSans-Bold'],
    'IBMPlexMono': ['IBMPlexMono-Medium', 'IBMPlexMono-SemiBold'],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
    }
    await loader.load();
  }
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  final icons = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.view(icons.readAsBytesSync().buffer)));
  await iconLoader.load();
}
