@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:craftbook/app.dart';
import 'package:craftbook/core/utils/currency_formatter.dart';
import 'package:craftbook/core/utils/currency_setting.dart';
import 'package:craftbook/features/settings/domain/entities/tax_settings.dart';
import 'package:craftbook/features/settings/presentation/bloc/tax_settings_cubit.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/theme/palettes.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/orders/presentation/widgets/note_field.dart';
import 'package:craftbook/features/settings/presentation/pages/about_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/sample_data.dart';

/// Renders the real app, against an in-memory database seeded with a sample
/// shop, and saves each screen as a PNG under goldens/.
void main() {
  setUpAll(() async {
    await _loadFonts();
  });

  final now = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  final weekEnd =
      DateTime(weekStart.year, weekStart.month, weekStart.day + 6, 23, 59, 59);

  final screens = <(String, String)>[
    ('today', RouteNames.today),
    ('orders', RouteNames.orders),
    ('new_order', RouteNames.newOrder),
    ('edit_order', RouteNames.editOrderPath(8)),
    ('edit_order_packed', RouteNames.editOrderPath(10)),
    ('edit_order_shipped', RouteNames.editOrderPath(4)),
    ('order_overdue', RouteNames.orderPath(8)),
    ('order_packed', RouteNames.orderPath(10)),
    ('order_shipped', RouteNames.orderPath(4)),
    ('calendar_week', RouteNames.calendarWeek),
    ('calendar_month', RouteNames.calendarMonth),
    ('stock', RouteNames.materials),
    ('material_detail', RouteNames.materialPath(1)),
    ('receive_stock', RouteNames.receiveStockPath(1)),
    ('new_material', RouteNames.newMaterial),
    ('edit_material', RouteNames.editMaterialPath(1)),
    ('buy_list', RouteNames.buyList),
    ('products', RouteNames.products),
    ('product_detail', RouteNames.productPath(1)),
    ('product_detail_resell', RouteNames.productPath(4)),
    ('product_editor', RouteNames.productEditorPath(1)),
    ('product_resell', RouteNames.productEditorPath(4)),
    ('channels', RouteNames.channels),
    ('order_fields', RouteNames.orderFields),
    ('social_shortcuts', RouteNames.socialLinks),
    ('discounts', RouteNames.discounts),
    ('reports', RouteNames.reports),
    ('receivables', RouteNames.receivables),
    (
      'product_report',
      RouteNames.productReportPath(
          1, weekStart.subtract(const Duration(days: 28)), weekEnd)
    ),
    ('more', RouteNames.settings),
    ('notes', RouteNames.notes),
    ('note_edit', RouteNames.notePath(1)),
    ('about', RouteNames.about),
  ];

  for (final (name, route) in screens) {
    for (final dark in [false, true]) {
      testWidgets('$name ${dark ? 'dark' : 'light'}', (tester) async {
        // rootBundle caches, so reading the README outside the fake-async
        // zone lets the About page resolve instantly once it asks for it.
        if (name == 'about') {
          await tester
              .runAsync(() => rootBundle.loadString(AboutPage.readmeAsset));
        }
        await _boot(tester, route, dark);
        await expectLater(
          find.byType(CraftbookApp),
          matchesGoldenFile('goldens/${name}_${dark ? 'dark' : 'light'}.png'),
        );
        await _teardown(tester);
      });
    }
  }

  // The other colour schemes, on the screens that show the most colour.
  for (final palette
      in AppPalette.values.where((p) => p != AppPalette.forest)) {
    for (final (name, route) in [
      ('today', RouteNames.today),
      ('orders', RouteNames.orders),
      ('reports', RouteNames.reports),
      ('more', RouteNames.settings),
    ]) {
      for (final dark in [false, true]) {
        final file = '${name}_${palette.name}_${dark ? 'dark' : 'light'}';
        testWidgets(file, (tester) async {
          await _boot(tester, route, dark, palette);
          await expectLater(find.byType(CraftbookApp),
              matchesGoldenFile('goldens/$file.png'));
          await _teardown(tester);
        });
      }
    }
  }

  // The history sits at the bottom of the product page, so scroll down to it.
  for (final (name, id) in [
    ('product_history', 1),
    ('product_resell_history', 4)
  ]) {
    for (final dark in [false, true]) {
      testWidgets('$name ${dark ? 'dark' : 'light'}', (tester) async {
        await _boot(tester, RouteNames.productPath(id), dark);
        await tester.scrollUntilVisible(find.text('HISTORY'), 300,
            scrollable: find.byType(Scrollable).first);
        await tester.drag(
            find.byType(Scrollable).first, const Offset(0, -2000));
        await _settle(tester);
        await expectLater(
          find.byType(CraftbookApp),
          matchesGoldenFile('goldens/${name}_${dark ? 'dark' : 'light'}.png'),
        );
        await _teardown(tester);
      });
    }
  }

  // Sheets and states that only show after a tap.
  testWidgets('reports filtered', (tester) async {
    await _boot(tester, RouteNames.reports, false);
    await tester.tap(find.byTooltip('Filter'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp),
        matchesGoldenFile('goldens/reports_filter_sheet_light.png'));
    await tester.tap(find.text('Walk-in'));
    await tester.ensureVisible(find.text('Show'));
    await tester.tap(find.text('Show'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp),
        matchesGoldenFile('goldens/reports_filtered_light.png'));
    await _teardown(tester);
  });

  testWidgets('reports custom range', (tester) async {
    await _boot(tester, RouteNames.reports, false);
    await tester.tap(find.text('Custom'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp),
        matchesGoldenFile('goldens/reports_range_picker_light.png'));
    await _teardown(tester);
  });

  for (final (name, row) in [
    ('currency_sheet', 'Currency'),
    ('tax_sheet', 'Tax')
  ]) {
    testWidgets(name, (tester) async {
      await _boot(tester, RouteNames.settings, false);
      await tester.tap(find.text(row));
      await _settle(tester);
      await expectLater(find.byType(CraftbookApp),
          matchesGoldenFile('goldens/${name}_light.png'));
      await _teardown(tester);
    });
  }

  // Another currency, to check every amount follows it.
  testWidgets('reports in dollars', (tester) async {
    CurrencyFormatter.configure(CurrencySetting.preset('USD')!);
    addTearDown(() => CurrencyFormatter.configure(CurrencySetting.php));
    await _boot(tester, RouteNames.reports, false);
    await expectLater(find.byType(CraftbookApp),
        matchesGoldenFile('goldens/reports_usd_light.png'));
    await _teardown(tester);
  });

  testWidgets('pack sheet', (tester) async {
    await _boot(tester, RouteNames.orderPath(8), false);
    await tester.tap(find.text('Pack order'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp),
        matchesGoldenFile('goldens/pack_sheet_light.png'));
    await _teardown(tester);
  });

  // Without tax the discounts sit straight above the paid switch.
  testWidgets('new order review without tax', (tester) async {
    await _boot(tester, RouteNames.newOrder, false);
    await tester
        .runAsync(() => getIt<TaxSettingsCubit>().set(const TaxSettings()));
    // The order form reads tax when it opens, so open it again.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(CraftbookApp(
        initialLocation: RouteNames.newOrder, themeMode: ThemeMode.light));
    await _settle(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Rina Velasco');
    await tester.tap(find.text('Next: add items'));
    await _settle(tester);
    await tester.tap(find.text('Add product').first);
    await _settle(tester);
    await tester.tap(find.text('Crochet tulip bouquet'));
    await _settle(tester);
    await tester.tap(find.text('Review'));
    await _settle(tester);
    await tester.tap(find.text('Bundle −₱50'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp),
        matchesGoldenFile('goldens/new_order_review_no_tax_light.png'));
    await _teardown(tester);
  });

  testWidgets('new order review', (tester) async {
    await _boot(tester, RouteNames.newOrder, false);
    await tester.enterText(find.byType(TextFormField).first, 'Rina Velasco');
    await tester.tap(find.text('Next: add items'));
    await _settle(tester);
    await tester.tap(find.text('Add product').first);
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp),
        matchesGoldenFile('goldens/product_picker_light.png'));
    await tester.tap(find.text('Crochet tulip bouquet'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp),
        matchesGoldenFile('goldens/new_order_items_light.png'));
    await tester.tap(find.text('Review'));
    await _settle(tester);
    await expectLater(find.byType(CraftbookApp),
        matchesGoldenFile('goldens/new_order_review_light.png'));
    await _teardown(tester);
  });

  // The rich-text note editor, opened from the order form on Ana's checklist
  // note. Both themes, since the toolbar and the editor content are themed
  // separately.
  for (final dark in [false, true]) {
    testWidgets('note editor ${dark ? 'dark' : 'light'}', (tester) async {
      await _boot(tester, RouteNames.editOrderPath(10), dark);
      // Packed orders show their money above the note.
      await tester.drag(
          find.byType(CustomScrollView).first, const Offset(0, -1500));
      await _settle(tester);
      await tester.tap(find.byType(NoteField));
      await _settle(tester);
      await expectLater(
        find.byType(CraftbookApp),
        matchesGoldenFile('goldens/note_editor_${dark ? 'dark' : 'light'}.png'),
      );
      await _teardown(tester);
    });
  }
}

Future<void> _boot(
  WidgetTester tester,
  String route,
  bool dark, [
  AppPalette palette = AppPalette.forest,
]) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  // Draw real shadows instead of the test framework's outline stand-ins.
  debugDisableShadows = false;
  await tester.runAsync(() async {
    await getIt.reset();
    await configureDependencies(
        database: AppDatabase.forTesting(NativeDatabase.memory()));
    await seedSampleShop();
  });
  await tester.pumpWidget(CraftbookApp(
    initialLocation: route,
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    palette: palette,
  ));
  await _settle(tester);
}

/// Lets real database futures finish, then draws frames.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
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
    'Bricolage': [
      'BricolageGrotesque-Medium',
      'BricolageGrotesque-SemiBold',
      'BricolageGrotesque-Bold'
    ],
    'IBMPlexSans': [
      'IBMPlexSans-Regular',
      'IBMPlexSans-Medium',
      'IBMPlexSans-SemiBold',
      'IBMPlexSans-Bold'
    ],
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
  final icons = File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.view(icons.readAsBytesSync().buffer)));
  await iconLoader.load();
}
