/// The "I can see the app works" check: seed the app's own fake shop into a
/// real in-memory database, then open every screen and demand that it renders
/// without throwing and shows what the seeder wrote. A regression that only
/// shows up visually — a page that renders empty, a screen that throws on a
/// fractional quantity — fails here instead of under a human's thumb.
///
/// Every id, name and number asserted against is read back from the database
/// through the app's own repositories: the seed's counts vary, so nothing here
/// is hardcoded. The standard seed (no number passed) keeps a failure
/// reproducible.
library;

import 'dart:io';

import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/utils/currency_formatter.dart';
import 'package:craftbook/core/utils/quantity.dart';
import 'package:craftbook/core/utils/quantity_formatter.dart';
import 'package:craftbook/core/widgets/app_card.dart';
import 'package:craftbook/core/widgets/app_tag.dart';
import 'package:craftbook/core/widgets/choice_chip_row.dart';
import 'package:craftbook/core/widgets/money_breakdown.dart';
import 'package:craftbook/features/debug/domain/usecases/seed_fake_shop.dart';
import 'package:craftbook/features/discounts/domain/entities/discount_preset.dart';
import 'package:craftbook/features/discounts/domain/repositories/discount_preset_repository.dart';
import 'package:craftbook/features/earnings/domain/entities/earnings_summary.dart';
import 'package:craftbook/features/earnings/domain/entities/report_period.dart';
import 'package:craftbook/features/earnings/domain/usecases/get_earnings_summary.dart';
import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:craftbook/features/notes/domain/usecases/get_notes.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/domain/repositories/order_field_repository.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/get_receivables.dart';
import 'package:craftbook/features/orders/presentation/widgets/order_status_ui.dart';
import 'package:craftbook/features/products/domain/entities/channel.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/social_links/domain/entities/social_link.dart';
import 'package:craftbook/features/social_links/domain/repositories/social_link_repository.dart';
import 'package:craftbook/features/stock/domain/entities/buy_list_item.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:craftbook/features/units/domain/entities/unit_of_measure.dart';
import 'package:craftbook/features/units/domain/repositories/unit_repository.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

/// The standard shop, written through the app's own use cases into the test
/// database.
Future<void> _seed(WidgetTester tester) async {
  await startApp(tester, seed: () async => ok(await getIt<SeedFakeShop>()()));
}

/// The shop, then the app opened at [route] on a phone-sized screen.
Future<void> _boot(WidgetTester tester, String route) async {
  await _seed(tester);
  await openApp(tester, route);
  expect(tester.takeException(), isNull, reason: 'opening $route threw');
}

Future<List<Order>> _orders(WidgetTester tester) => db<List<Order>>(
    tester, () async => ok(await getIt<OrderRepository>().getAllOrders()));

Future<List<Product>> _products(WidgetTester tester) => db<List<Product>>(
    tester, () async => ok(await getIt<ProductRepository>().getAllProducts()));

Future<List<Material>> _materials(WidgetTester tester) => db<List<Material>>(
    tester,
    () async => ok(await getIt<MaterialRepository>().getAllMaterials()));

Future<List<BuyListItem>> _buyList(WidgetTester tester) =>
    db<List<BuyListItem>>(
        tester, () async => ok(await getIt<MaterialRepository>().getBuyList()));

Future<List<Note>> _notes(WidgetTester tester) =>
    db<List<Note>>(tester, () async => ok(await getIt<GetNotes>()()));

Future<List<Channel>> _channels(WidgetTester tester) => db<List<Channel>>(
    tester, () async => ok(await getIt<ChannelRepository>().getAllChannels()));

Future<List<DiscountPreset>> _presets(WidgetTester tester) =>
    db<List<DiscountPreset>>(tester,
        () async => ok(await getIt<DiscountPresetRepository>().getPresets()));

Future<List<UnitOfMeasure>> _units(WidgetTester tester) =>
    db<List<UnitOfMeasure>>(
        tester, () async => ok(await getIt<UnitRepository>().getUnits()));

Future<List<OrderField>> _fields(WidgetTester tester) => db<List<OrderField>>(
    tester, () async => ok(await getIt<OrderFieldRepository>().getFields()));

Future<List<SocialLink>> _links(WidgetTester tester) => db<List<SocialLink>>(
    tester, () async => ok(await getIt<SocialLinkRepository>().getLinks()));

Future<Receivables> _receivables(WidgetTester tester) =>
    db<Receivables>(tester, () async => ok(await getIt<GetReceivables>()()));

Future<EarningsSummary> _summary(
  WidgetTester tester,
  DateTime start,
  DateTime end,
) =>
    db<EarningsSummary>(
        tester, () async => ok(await getIt<GetEarningsSummary>()(start, end)));

/// The first item the filter accepts. The seed's own coverage contract
/// guarantees these states exist, so falling through is a seed regression,
/// said in the words a future reader can act on.
T _pick<T>(List<T> items, bool Function(T) wanted, String what) {
  for (final item in items) {
    if (wanted(item)) return item;
  }
  throw StateError('the seeded shop never produced $what');
}

bool _isFraction(double quantity) =>
    !sameQty(quantity, quantity.roundToDouble());

/// Rows under the fold are not built yet, so drag the page's own list until
/// [target] appears. Bounded, and it gives up quietly when the page has no
/// plain list to drag — the expect that follows then fails with the seeded
/// value in its reason, which is the message worth reading.
Future<void> _reveal(WidgetTester tester, Finder target) async {
  final list = find.byType(ListView);
  for (var i = 0;
      i < 16 && target.evaluate().isEmpty && list.evaluate().isNotEmpty;
      i++) {
    await tester.drag(list.first, const Offset(0, -260));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Finder _chipWith(String label) => find.widgetWithText(AppChip, label);

Future<void> _tapChip(WidgetTester tester, String label) async {
  final chip = _chipWith(label);
  await tester.ensureVisible(chip);
  await tester.pump();
  await tester.tap(chip);
  await settle(tester);
  expect(tester.takeException(), isNull,
      reason: 'tapping the $label chip threw');
}

/// The test framework's stand-in font draws every glyph as a full-width
/// square, so a seeded 40-character name that fits on a phone "overflows"
/// here and fails the run with noise. Load the fonts the app actually ships,
/// the way the golden suite does, so these pages fight the same text metrics
/// a shop owner's phone does.
Future<void> _loadAppFonts() async {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadAppFonts);

  group('the seeded shop, screen by screen', () {
    testWidgets('Today shows the board and the overdue order', (tester) async {
      await _boot(tester, RouteNames.today);
      final orders = await _orders(tester);
      final notes = await _notes(tester);

      // The board is the page's own headline numbers.
      expect(find.text('TO PACK TODAY'), findsOneWidget);
      // StatusPill and BoardStat both draw their text uppercased, and the
      // word appears once on the board and once per overdue card's pill.
      expect(find.text('OVERDUE'), findsWidgets);
      expect(find.text('WEEK PROFIT'), findsOneWidget);

      // The Overdue stat is the count of overdue pending orders, and the
      // most overdue order sits at the head of the list under it.
      final overdueCount = orders.where((o) => o.isOverdue).length;
      expect(find.text('$overdueCount'), findsWidgets,
          reason: 'the Overdue stat is not counting $overdueCount orders');
      final overdue = _pick(orders, (o) => o.isOverdue, 'an overdue order');
      await _reveal(tester, find.text(overdue.customerName));
      expect(find.text(overdue.customerName), findsWidgets,
          reason: 'the most overdue order is missing from Today');

      final pinned =
          _pick(notes, (n) => n.isPinned, 'a pinned note for the board');
      expect(find.text(pinned.displayTitle), findsWidgets,
          reason: 'the pinned note does not reach Today');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Orders opens on pending work with an Overdue pill',
        (tester) async {
      await _boot(tester, RouteNames.orders);
      final orders = await _orders(tester);
      final overdue = _pick(
          orders,
          (o) => o.status == OrderStatus.pending && o.isOverdue,
          'an overdue pending order');

      // The page opens on the To pack pile, grouped by urgency, so the
      // overdue order is the first card and its pill reads "OVERDUE"
      // (StatusPill paints uppercased).
      expect(find.text('OVERDUE'), findsWidgets,
          reason: 'no overdue pill on the orders list');
      expect(find.text(overdue.customerName), findsWidgets,
          reason: 'the overdue order is not in the pile the page opens on');
      final pendingCount =
          orders.where((o) => o.status == OrderStatus.pending).length;
      expect(
          find.descendant(
              of: _chipWith('To pack'), matching: find.text('$pendingCount')),
          findsOneWidget,
          reason:
              'the To pack chip does not count $pendingCount pending orders');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Orders status chips each reveal their pile', (tester) async {
      await _boot(tester, RouteNames.orders);
      final orders = await _orders(tester);

      await _tapChip(tester, 'All');
      final openCount =
          orders.where((o) => o.status != OrderStatus.cancelled).length;
      expect(
          find.descendant(
              of: _chipWith('All'), matching: find.text('$openCount')),
          findsOneWidget,
          reason: 'the All chip does not count the $openCount open orders');

      Future<void> pileOf(OrderStatus status) async {
        await _tapChip(tester, status.label);
        final inPile =
            _pick(orders, (o) => o.status == status, 'a ${status.name} order');
        await _reveal(tester, find.text(inPile.customerName));
        expect(find.text(inPile.customerName), findsWidgets,
            reason: 'the ${status.label} chip hides ${inPile.customerName}');
      }

      await pileOf(OrderStatus.packed);
      await pileOf(OrderStatus.shipped);
      await pileOf(OrderStatus.cancelled);

      // Cancelled orders live only under their own chip.
      await _tapChip(tester, 'To pack');
      final cancelled = _pick(orders, (o) => o.status == OrderStatus.cancelled,
          'a cancelled order');
      expect(find.text(cancelled.customerName), findsNothing,
          reason: 'a cancelled order leaked into the To pack pile');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Products lists the catalogue', (tester) async {
      await _boot(tester, RouteNames.products);
      final products = await _products(tester);
      final handmade = _pick(products, (p) => !p.isStandalone && !p.isArchived,
          'a handmade product');
      final resell = _pick(
          products, (p) => p.isStandalone && !p.isArchived, 'a resell product');

      await _reveal(tester, find.text(handmade.name));
      expect(find.text(handmade.name), findsWidgets,
          reason: 'the handmade product is not in the list');
      await _reveal(tester, find.text(resell.name));
      expect(find.text(resell.name), findsWidgets,
          reason: 'the resell product is not in the list');
      expect(find.widgetWithText(AppTag, 'RESELL'), findsWidgets,
          reason: 'nothing in the list is marked as resold');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Materials shows a fractional or empty number', (tester) async {
      // The Materials tab of the Products page; /materials redirects there.
      await _boot(tester, RouteNames.materials);
      expect(find.widgetWithText(Tab, 'Materials'), findsOneWidget);
      final materials = await _materials(tester);
      final odd = _pick(
          materials,
          (m) =>
              !m.isArchived &&
              (_isFraction(m.quantityOnHand) || sameQty(m.quantityOnHand, 0)),
          'a fractional or empty material');

      await _reveal(tester, find.text(odd.name));
      expect(find.text(odd.name), findsWidgets,
          reason: 'the material is missing from the list');
      expect(
          find.text(QuantityFormatter.format(odd.quantityOnHand)), findsWidgets,
          reason: 'the shelf does not show ${odd.name} at '
              '${QuantityFormatter.format(odd.quantityOnHand)}');
      // The card prices the material in its own unit, spelled as typed.
      expect(find.textContaining('/${odd.unit}'), findsWidgets,
          reason: 'no cost line carries the ${odd.unit} unit');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Buy list asks for whole packs', (tester) async {
      await _boot(tester, RouteNames.buyList);
      final buyList = await _buyList(tester);
      final multi = _pick(
          buyList,
          (i) => i.kind == BuyListKind.material && i.packsToOrder > 1,
          'a buy line needing more than one pack');
      final resell = _pick(
          buyList, (i) => i.kind == BuyListKind.product, 'a resell to buy');
      final fractional = _pick(buyList, (i) => _isFraction(i.quantityOnHand),
          'a fractional quantity on the list');

      await _reveal(tester, find.text(multi.name));
      expect(
          find.textContaining(
              'Buy ${multi.packsToOrder} ${multi.packsToOrder == 1 ? 'pack' : 'packs'}'),
          findsWidgets,
          reason: '${multi.name} does not ask for ${multi.packsToOrder} packs');
      await _reveal(tester, find.text(resell.name));
      expect(find.text(resell.name), findsWidgets,
          reason: 'the resell product never reaches the buy list');
      await _reveal(tester, find.text(fractional.name));
      expect(find.textContaining(fractional.unit), findsWidgets,
          reason: 'no buy line spells out the ${fractional.unit} unit');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Channels lists every channel', (tester) async {
      await _boot(tester, RouteNames.channels);
      final channels = await _channels(tester);
      expect(channels, isNotEmpty, reason: 'the seed wrote no channels');
      for (final channel in channels) {
        await _reveal(tester, find.text(channel.name));
        expect(find.text(channel.name), findsWidgets,
            reason: '${channel.name} is missing from the channels page');
      }
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Discounts lists every preset', (tester) async {
      await _boot(tester, RouteNames.discounts);
      final presets = await _presets(tester);
      expect(presets, isNotEmpty, reason: 'the seed wrote no presets');
      for (final preset in presets) {
        await _reveal(tester, find.text(preset.label));
        expect(find.text(preset.label), findsWidgets,
            reason: 'the preset "${preset.label}" is missing');
      }
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Units lists the shop vocabulary', (tester) async {
      await _boot(tester, RouteNames.units);
      final units = await _units(tester);
      // 'dozen' is the label the fake shop invented, so it can only have
      // come from the seed.
      final invented =
          _pick(units, (u) => u.label == 'dozen', 'the invented dozen unit');
      await _reveal(tester, find.text(invented.label));
      for (final unit in units.take(4)) {
        expect(find.text(unit.label), findsWidgets,
            reason: '${unit.label} is missing from the unit list');
      }
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets("Order fields lists the shop's own questions", (tester) async {
      await _boot(tester, RouteNames.orderFields);
      final fields = await _fields(tester);
      final live = fields.where((f) => !f.isArchived).toList();
      expect(live, isNotEmpty, reason: 'the seed archived every field');
      for (final field in live) {
        await _reveal(tester, find.text(field.name));
        expect(find.text(field.name), findsWidgets,
            reason: '${field.name} is missing from the field list');
      }
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Social shortcuts lists every link', (tester) async {
      await _boot(tester, RouteNames.socialLinks);
      final links = await _links(tester);
      expect(links, isNotEmpty, reason: 'the seed wrote no shortcuts');
      for (final link in links) {
        await _reveal(tester, find.text(link.label));
        expect(find.text(link.label), findsWidgets,
            reason: '${link.label} is missing from the shortcuts');
      }
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Notes lists the notebook', (tester) async {
      await _boot(tester, RouteNames.notes);
      final notes = await _notes(tester);
      for (final note in notes) {
        await _reveal(tester, find.text(note.displayTitle));
        expect(find.text(note.displayTitle), findsWidgets,
            reason: 'the note "${note.displayTitle}" is missing');
      }
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Reports nets out the seeded profit', (tester) async {
      await _boot(tester, RouteNames.reports);

      // Month, not the default week: the seed only guarantees a month holds
      // packed or shipped orders, and the report's own period maths is
      // re-derived rather than retyped.
      await tester.tap(find.text('Month'));
      await settle(tester);
      expect(tester.takeException(), isNull,
          reason: 'switching the report to a month threw');
      final now = DateTime.now();
      final period = const ReportPeriod(ReportRange.month).resolve(now);
      final summary = await _summary(tester, period.start, period.end);
      final parts = MoneyParts(
        sales: summary.totalSales,
        discount: summary.totalDiscount,
        includedTax: summary.totalIncludedTax,
        addedTax: summary.totalAddedTax,
        materials: summary.totalMaterialCost,
        fees: summary.totalChannelFees,
        shipping: summary.totalShippingCost,
      );
      expect(summary.orderCount, greaterThan(0),
          reason: 'this month holds no packed or shipped order to report');
      expect(parts.profit, isNot(0),
          reason: 'the seeded month nets out to exactly zero');

      // SummaryBoard draws its label uppercased; the value is the formatted
      // profit, recomputed here from the same totals the page reads.
      expect(
          find.text('Net profit · ${summary.orderCount} orders'.toUpperCase()),
          findsOneWidget,
          reason: 'the board does not count the month\'s orders');
      expect(find.text(CurrencyFormatter.formatShort(parts.profit)),
          findsOneWidget,
          reason: 'the profit on screen is not the profit in the database');

      // Unpaid orders are guaranteed, and their all-time card lives here.
      expect(find.text('Waiting for payment'), findsOneWidget,
          reason: 'the receivables card is missing from Reports');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Waiting for payment names the debtors', (tester) async {
      await _boot(tester, RouteNames.receivables);
      final receivables = await _receivables(tester);
      expect(receivables.orderCount, greaterThan(0),
          reason: 'the seed owes somebody nothing');

      // The board spells the all-time total up front, exactly as the page's
      // own formatter renders it.
      expect(find.textContaining('OWED TO YOU'), findsOneWidget,
          reason: 'the receivables board is missing');
      expect(find.text(CurrencyFormatter.formatShort(receivables.total)),
          findsOneWidget,
          reason: 'the board total is not the total in the database');

      final debtor = receivables.groups.first;
      await _reveal(tester, find.textContaining(debtor.customerName));
      expect(find.textContaining(debtor.customerName), findsWidgets,
          reason: '${debtor.customerName} is missing from receivables');
      // Each unpaid order of that customer is a card, and each card carries
      // its order number.
      for (final entry in debtor.entries) {
        await _reveal(tester, find.text('#${entry.order.id}'));
        expect(find.text('#${entry.order.id}'), findsWidgets,
            reason: 'order #${entry.order.id} of ${debtor.customerName} '
                'is missing');
      }
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('More carries the settings and the debug rows', (tester) async {
      await _boot(tester, RouteNames.settings);
      expect(find.text('Currency'), findsOneWidget);
      await _reveal(tester, find.text('Waiting for payment'));
      expect(find.text('Waiting for payment'), findsOneWidget,
          reason: 'the receivables row is gone from the hub');
      // Widget tests run debug builds, so the Debug group is mounted.
      await _reveal(tester, find.text('Seed fake data'));
      expect(find.text('Seed fake data'), findsOneWidget,
          reason: 'the debug group is not mounted on a debug build');
      expect(find.text('Database & coverage'), findsOneWidget,
          reason: 'no way into the coverage page from More');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('Database & coverage says the shop exercised everything',
        (tester) async {
      await _boot(tester, RouteNames.debugDatabase);
      expect(find.text('Database & coverage'), findsOneWidget);
      expect(find.text('Schema'), findsOneWidget);
      expect(find.text('Every option the app offers showed up somewhere.'),
          findsOneWidget,
          reason: 'the seeded shop left the coverage page with gaps');
      // The Tables card sits under the fold, so its rows are not built yet.
      final orders = await _orders(tester);
      await _reveal(tester, find.text('orders'));
      expect(
          find.descendant(
              of: find.widgetWithText(CardRow, 'orders'),
              matching: find.text('${orders.length}')),
          findsOneWidget,
          reason: 'the orders table row does not count the '
              '${orders.length} seeded orders');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });
  });

  group('one detail page per interesting state', () {
    // These pages are addressed by id, so the seed runs first, the row is
    // read out of the database, and only then is its page opened.
    Future<Order> openOrder(WidgetTester tester, OrderStatus? status,
        {bool overdue = false}) async {
      await _seed(tester);
      final orders = await _orders(tester);
      final order = _pick(
          orders,
          (o) =>
              o.status == status &&
              (!overdue || (o.status == OrderStatus.pending && o.isOverdue)),
          overdue ? 'an overdue pending order' : 'a ${status!.name} order');
      await openApp(tester, RouteNames.orderPath(order.id!));
      expect(tester.takeException(), isNull,
          reason: 'the page for order #${order.id} threw');
      return order;
    }

    testWidgets('an overdue pending order', (tester) async {
      final order = await openOrder(tester, OrderStatus.pending, overdue: true);
      expect(find.text('ORDER #${order.id}'), findsOneWidget);
      expect(find.text(order.customerName),
          findsWidgets); // app bar and Customer card both print it
      expect(find.text('Pack order'), findsOneWidget,
          reason: 'a pending order offers no way to pack it');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('a packed order', (tester) async {
      final order = await openOrder(tester, OrderStatus.packed);
      expect(find.text('ORDER #${order.id}'), findsOneWidget);
      expect(find.text(order.customerName),
          findsWidgets); // app bar and Customer card both print it
      expect(find.text('Mark shipped'), findsOneWidget,
          reason: 'a packed order offers no way to ship it');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('a shipped order', (tester) async {
      final order = await openOrder(tester, OrderStatus.shipped);
      expect(find.text('ORDER #${order.id}'), findsOneWidget);
      expect(find.text(order.customerName),
          findsWidgets); // app bar and Customer card both print it
      expect(find.text('Shipped'), findsWidgets,
          reason: 'the status track lost the Shipped step');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('a cancelled order', (tester) async {
      final order = await openOrder(tester, OrderStatus.cancelled);
      expect(find.text('ORDER #${order.id}'), findsOneWidget);
      expect(find.text(order.customerName),
          findsWidgets); // app bar and Customer card both print it
      expect(find.text('CANCELLED'), findsWidgets,
          reason: 'the cancelled pill is missing');
      expect(find.text('Pack order'), findsNothing,
          reason: 'a cancelled order still offers packing');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('a handmade product page', (tester) async {
      await _seed(tester);
      final products = await _products(tester);
      final product = _pick(products, (p) => !p.isStandalone && !p.isArchived,
          'a handmade product');
      await openApp(tester, RouteNames.productPath(product.id!));
      expect(tester.takeException(), isNull, reason: 'the page threw');

      expect(find.text(product.name), findsWidgets);
      expect(find.text('CAN BUILD'), findsOneWidget,
          reason: 'the handmade headline is not a buildable count');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('a resell product page', (tester) async {
      await _seed(tester);
      final products = await _products(tester);
      final product = _pick(
          products, (p) => p.isStandalone && !p.isArchived, 'a resell product');
      await openApp(tester, RouteNames.productPath(product.id!));
      expect(tester.takeException(), isNull, reason: 'the page threw');

      expect(find.text(product.name), findsWidgets);
      expect(find.text('${product.unit.toUpperCase()} ON HAND'), findsOneWidget,
          reason: 'the resell headline is not counted in its own unit');
      expect(find.text(QuantityFormatter.format(product.quantityOnHand)),
          findsWidgets,
          reason: 'the shelf number is not the one in the database');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('a material at a fractional or empty number', (tester) async {
      await _seed(tester);
      final materials = await _materials(tester);
      final material = _pick(
          materials,
          (m) => _isFraction(m.quantityOnHand) || sameQty(m.quantityOnHand, 0),
          'a fractional or empty material');
      await openApp(tester, RouteNames.materialPath(material.id!));
      expect(tester.takeException(), isNull, reason: 'the page threw');

      expect(find.text(material.name), findsWidgets);
      expect(
          find.text('${material.unit.toUpperCase()} ON HAND'), findsOneWidget,
          reason: 'the headline is not counted in the stored unit');
      expect(find.text(QuantityFormatter.format(material.quantityOnHand)),
          findsWidgets,
          reason: 'the number on screen is not the number in the database: '
              '${QuantityFormatter.format(material.quantityOnHand)} expected');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('a note opens in the editor', (tester) async {
      await _seed(tester);
      final notes = await _notes(tester);
      final note =
          _pick(notes, (n) => n.title.isNotEmpty, 'a note with a title');
      await openApp(tester, RouteNames.notePath(note.id!));
      expect(tester.takeException(), isNull, reason: 'the editor threw');

      expect(find.text('Edit note'), findsOneWidget);
      expect(find.text(note.title), findsOneWidget,
          reason: 'the title is not the one the seed wrote');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });
  });
}
