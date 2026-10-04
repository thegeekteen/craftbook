import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/widgets/app_card.dart';
import 'package:craftbook/core/widgets/app_search_field.dart';
import 'package:craftbook/core/widgets/app_tag.dart';
import 'package:craftbook/core/widgets/bottom_action_bar.dart';
import 'package:craftbook/core/widgets/choice_chip_row.dart';
import 'package:craftbook/core/widgets/currency_text.dart';
import 'package:craftbook/core/widgets/date_field.dart';
import 'package:craftbook/core/widgets/empty_state.dart';
import 'package:craftbook/core/widgets/inline_banner.dart';
import 'package:craftbook/core/widgets/section_label.dart';
import 'package:craftbook/core/widgets/stat_tile.dart';
import 'package:craftbook/core/widgets/status_filter_chips.dart';
import 'package:craftbook/core/widgets/status_pill.dart';
import 'package:craftbook/core/widgets/summary_board.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  group('StatusPill', () {
    testWidgets('uppercases its text', (tester) async {
      await tester.pumpWidget(_wrap(const StatusPill(text: 'to pack')));
      expect(find.text('TO PACK'), findsOneWidget);
      expect(find.text('to pack'), findsNothing);
    });

    testWidgets('renders for every type', (tester) async {
      await tester.pumpWidget(_wrap(Column(
        children: [
          for (final t in StatusPillType.values)
            StatusPill(text: t.name, type: t),
        ],
      )));
      expect(tester.takeException(), isNull);
      for (final t in StatusPillType.values) {
        expect(find.text(t.name.toUpperCase()), findsOneWidget);
      }
    });
  });

  group('AppTag', () {
    testWidgets('uppercases status-like tags', (tester) async {
      await tester.pumpWidget(_wrap(const Column(children: [
        AppTag('Resell'),
        AppTag('Added', type: AppTagType.ok),
        AppTag('Soon', type: AppTagType.warn),
      ])));
      expect(find.text('RESELL'), findsOneWidget);
      expect(find.text('ADDED'), findsOneWidget);
      expect(find.text('SOON'), findsOneWidget);
    });

    testWidgets('outline type keeps its casing', (tester) async {
      await tester
          .pumpWidget(_wrap(const AppTag('Shopee', type: AppTagType.outline)));
      expect(find.text('Shopee'), findsOneWidget);
      expect(find.text('SHOPEE'), findsNothing);
    });

    testWidgets('AppTag.low shows LOW', (tester) async {
      await tester.pumpWidget(_wrap(const AppTag.low()));
      expect(find.text('LOW'), findsOneWidget);
      expect(tester.widget<AppTag>(find.byType(AppTag)).type, AppTagType.low);
    });
  });

  group('ChoiceChipRow', () {
    const options = [
      ChipOption('a', 'Alpha', count: 3),
      ChipOption('b', 'Beta'),
      ChipOption('c', 'Gamma', count: 0),
    ];

    testWidgets('single: tap calls onSelected with the value', (tester) async {
      String? picked;
      await tester.pumpWidget(_wrap(ChoiceChipRow<String>.single(
        options: options,
        selected: 'a',
        onSelected: (v) => picked = v,
      )));
      await tester.tap(find.text('Beta'));
      expect(picked, 'b');
    });

    testWidgets('renders labels and counts', (tester) async {
      await tester.pumpWidget(_wrap(ChoiceChipRow<String>.single(
        options: options,
        selected: 'a',
        onSelected: (_) {},
      )));
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('marks only the selected chip as selected', (tester) async {
      await tester.pumpWidget(_wrap(ChoiceChipRow<String>.single(
        options: options,
        selected: 'b',
        onSelected: (_) {},
      )));
      final chips = tester.widgetList<AppChip>(find.byType(AppChip)).toList();
      expect(chips.map((c) => c.selected), [false, true, false]);
    });

    testWidgets('scrolls horizontally by default', (tester) async {
      await tester.pumpWidget(_wrap(ChoiceChipRow<String>.single(
        options: options,
        selected: 'a',
        onSelected: (_) {},
      )));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('wrap mode lays out in a Wrap', (tester) async {
      await tester.pumpWidget(_wrap(ChoiceChipRow<String>.single(
        options: options,
        selected: 'a',
        onSelected: (_) {},
        wrap: true,
      )));
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('multi-select uses isSelected', (tester) async {
      await tester.pumpWidget(_wrap(ChoiceChipRow<String>(
        options: options,
        isSelected: (v) => v != 'b',
        onTap: (_) {},
      )));
      final chips = tester.widgetList<AppChip>(find.byType(AppChip)).toList();
      expect(chips.map((c) => c.selected), [true, false, true]);
    });
  });

  group('StatusFilterChips', () {
    final all = Set<OrderStatus>.from(OrderStatus.values);

    Future<List<Set<OrderStatus>>> pump(
      WidgetTester tester,
      Set<OrderStatus> selected, {
      Map<OrderStatus, int>? counts,
    }) async {
      final changes = <Set<OrderStatus>>[];
      await tester.pumpWidget(_wrap(StatusFilterChips(
        selected: selected,
        counts: counts,
        onChanged: changes.add,
      )));
      return changes;
    }

    testWidgets('shows All plus a chip per status', (tester) async {
      await pump(tester, all);
      for (final label in [
        'All',
        'To pack',
        'Packed',
        'Shipped',
        'Cancelled'
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('All is selected when every status is selected',
        (tester) async {
      await pump(tester, all);
      final chips = tester.widgetList<AppChip>(find.byType(AppChip)).toList();
      expect(chips.first.selected, isTrue);
      expect(chips.skip(1).every((c) => !c.selected), isTrue);
    });

    testWidgets('tapping a status selects only it', (tester) async {
      final changes = await pump(tester, all);
      await tester.tap(find.text('Packed'));
      expect(changes.single, {OrderStatus.packed});
    });

    testWidgets('tapping the only selected status goes back to all',
        (tester) async {
      final changes = await pump(tester, {OrderStatus.packed});
      await tester.tap(find.text('Packed'));
      expect(changes.single, all);
    });

    testWidgets('tapping another status switches to it', (tester) async {
      final changes = await pump(tester, {OrderStatus.packed});
      await tester.tap(find.text('Shipped'));
      expect(changes.single, {OrderStatus.shipped});
    });

    testWidgets('tapping All selects all statuses', (tester) async {
      final changes = await pump(tester, {OrderStatus.pending});
      await tester.tap(find.text('All'));
      expect(changes.single, all);
    });

    testWidgets('All shows the total of the counts', (tester) async {
      await pump(tester, all, counts: {
        OrderStatus.pending: 2,
        OrderStatus.packed: 3,
        OrderStatus.shipped: 4,
      });
      expect(find.text('9'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('custom statuses limit the chips', (tester) async {
      await tester.pumpWidget(_wrap(StatusFilterChips(
        selected: all,
        onChanged: (_) {},
        statuses: const [OrderStatus.pending, OrderStatus.packed],
      )));
      expect(find.text('Shipped'), findsNothing);
      expect(find.text('Cancelled'), findsNothing);
      expect(find.byType(AppChip), findsNWidgets(3));
    });
  });

  group('SummaryBoard', () {
    testWidgets('uppercases label and shows value and stats', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(SummaryBoard(
        label: 'This week',
        value: '₱1,250',
        stats: const [
          BoardStat(label: 'Orders', value: '12'),
          BoardStat(label: 'Overdue', value: '2', labelColor: Colors.red),
        ],
        onTap: () => taps++,
      )));
      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text('₱1,250'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('ORDERS'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('OVERDUE'), findsOneWidget);
      await tester.tap(find.text('₱1,250'));
      expect(taps, 1);
    });

    testWidgets('renders optional child and no stats', (tester) async {
      await tester.pumpWidget(_wrap(const SummaryBoard(
        label: 'Profit',
        value: '₱0',
        child: Text('chart'),
      )));
      expect(find.text('chart'), findsOneWidget);
      expect(find.text('PROFIT'), findsOneWidget);
    });
  });

  group('StatTile', () {
    testWidgets('uppercases label and shows value', (tester) async {
      await tester.pumpWidget(_wrap(const StatRow(children: [
        StatTile(label: 'Unit cost', value: '₱2.50'),
        StatTile(label: 'Supplier', value: 'Divisoria', compact: true),
      ])));
      expect(find.text('UNIT COST'), findsOneWidget);
      expect(find.text('₱2.50'), findsOneWidget);
      expect(find.text('SUPPLIER'), findsOneWidget);
      expect(find.text('Divisoria'), findsOneWidget);
      expect(find.byType(Expanded), findsNWidgets(2));
    });

    testWidgets('value colour override applies', (tester) async {
      await tester.pumpWidget(_wrap(const StatTile(
        label: 'Loss',
        value: '−₱5',
        valueColor: Colors.red,
      )));
      expect(tester.widget<Text>(find.text('−₱5')).style?.color, Colors.red);
    });
  });

  group('EmptyState', () {
    testWidgets('shows title and message', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyState(
        icon: Icons.inbox,
        title: 'No orders yet',
        message: 'Orders you add show up here.',
      )));
      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.text('Orders you add show up here.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('action shows and fires with label and callback',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(EmptyState(
        icon: Icons.inbox,
        title: 'Empty',
        actionLabel: 'Add order',
        onAction: () => taps++,
      )));
      await tester.tap(find.text('Add order'));
      expect(taps, 1);
    });

    testWidgets('no action without callback', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyState(
        icon: Icons.inbox,
        title: 'Empty',
        actionLabel: 'Add order',
      )));
      expect(find.text('Add order'), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('no action without label', (tester) async {
      await tester.pumpWidget(_wrap(EmptyState(
        icon: Icons.inbox,
        title: 'Empty',
        onAction: () {},
      )));
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });

  group('ErrorState', () {
    testWidgets('shows message and Try again that retries', (tester) async {
      var retries = 0;
      await tester.pumpWidget(_wrap(ErrorState(
        message: 'Database locked',
        onRetry: () => retries++,
      )));
      expect(find.text("Couldn't load this"), findsOneWidget);
      expect(find.text('Database locked'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('no retry button without onRetry', (tester) async {
      await tester.pumpWidget(_wrap(const ErrorState(message: 'Oops')));
      expect(find.text('Try again'), findsNothing);
    });
  });

  group('BottomActionBar / BarTotal', () {
    testWidgets('BarTotal uppercases label and shows value and trailing',
        (tester) async {
      var saved = 0;
      await tester.pumpWidget(_wrap(Align(
        alignment: Alignment.bottomCenter,
        child: BottomActionBar(children: [
          const BarTotal(
              label: 'Total', value: '₱935', trailing: Text('3 items')),
          FilledButton(onPressed: () => saved++, child: const Text('Save')),
        ]),
      )));
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('₱935'), findsOneWidget);
      expect(find.text('3 items'), findsOneWidget);
      await tester.tap(find.text('Save'));
      expect(saved, 1);
    });
  });

  group('InlineBanner', () {
    testWidgets('shows title, message, action and fires on tap',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(InlineBanner(
        icon: Icons.warning_amber_rounded,
        title: '3 materials low.',
        message: 'Restock soon.',
        actionLabel: 'Buy list',
        tone: BannerTone.warn,
        onTap: () => taps++,
      )));
      expect(find.text('3 materials low. Restock soon.'), findsOneWidget);
      expect(find.text('Buy list'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      await tester.tap(find.byType(InlineBanner));
      expect(taps, 1);
    });

    testWidgets('renders every tone without action', (tester) async {
      await tester.pumpWidget(_wrap(Column(children: [
        for (final t in BannerTone.values)
          InlineBanner(icon: Icons.info, title: t.name, tone: t),
      ])));
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });
  });

  group('AppCard / CardList / CardRow', () {
    testWidgets('AppCard onTap fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(AppCard(
        onTap: () => taps++,
        child: const Text('Card body'),
      )));
      await tester.tap(find.text('Card body'));
      expect(taps, 1);
    });

    testWidgets('AppCard.flush has no padding', (tester) async {
      await tester.pumpWidget(_wrap(const AppCard.flush(child: Text('x'))));
      final card = tester.widget<AppCard>(find.byType(AppCard));
      expect(card.padding, EdgeInsets.zero);
    });

    testWidgets('CardList inserts dividers between rows only', (tester) async {
      await tester.pumpWidget(_wrap(const AppCard.flush(
        child: CardList(children: [
          CardRow(title: Text('One')),
          CardRow(title: Text('Two')),
          CardRow(title: Text('Three')),
        ]),
      )));
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.text('Three'), findsOneWidget);
    });

    testWidgets('CardList with one row has no divider', (tester) async {
      await tester.pumpWidget(_wrap(const CardList(children: [Text('Solo')])));
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('CardRow shows leading, subtitle, trailing and taps',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(CardRow(
        leading: const Icon(Icons.star),
        title: const Text('Title'),
        subtitle: const Text('Sub'),
        trailing: const Text('Trail'),
        onTap: () => taps++,
      )));
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Sub'), findsOneWidget);
      expect(find.text('Trail'), findsOneWidget);
      await tester.tap(find.text('Title'));
      expect(taps, 1);
    });
  });

  group('SectionLabel / SectionAction', () {
    testWidgets('label is uppercased', (tester) async {
      await tester.pumpWidget(_wrap(const SectionLabel('Materials')));
      expect(find.text('MATERIALS'), findsOneWidget);
    });

    testWidgets('SectionAction tap fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(SectionLabel(
        'Items',
        trailing:
            SectionAction(label: 'Add', icon: Icons.add, onTap: () => taps++),
      )));
      expect(find.text('Add'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.text('Add'));
      expect(taps, 1);
    });
  });

  group('DateField', () {
    testWidgets('shows a weekday date for this year', (tester) async {
      final value = DateTime(DateTime.now().year, 10, 7);
      await tester.pumpWidget(_wrap(DateField(
        label: 'Ship by',
        value: value,
        onChanged: (_) {},
      )));
      expect(find.text('Ship by'), findsOneWidget);
      expect(find.text(DateFormat('EEE, MMM d').format(value)), findsOneWidget);
    });

    testWidgets('formats Oct 7 2026 as Wed, Oct 7 in 2026', (tester) async {
      // Only meaningful while the clock is in 2026; otherwise the year is shown.
      final value = DateTime(2026, 10, 7);
      await tester.pumpWidget(_wrap(DateField(
        label: 'Ship by',
        value: value,
        onChanged: (_) {},
      )));
      final expected =
          DateTime.now().year == 2026 ? 'Wed, Oct 7' : 'Oct 7, 2026';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('shows the year for other years', (tester) async {
      final value = DateTime(DateTime.now().year - 3, 3, 5);
      await tester.pumpWidget(_wrap(DateField(
        label: 'Ordered',
        value: value,
        onChanged: (_) {},
      )));
      expect(find.text('Mar 5, ${value.year}'), findsOneWidget);
    });

    testWidgets('tapping opens a date picker and returns the pick',
        (tester) async {
      final value = DateTime(DateTime.now().year, 6, 15);
      DateTime? picked;
      await tester.pumpWidget(_wrap(DateField(
        label: 'Ship by',
        value: value,
        onChanged: (d) => picked = d,
      )));
      await tester.tap(find.byType(DateField));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text('SHIP BY'), findsOneWidget);
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(picked, DateTime(value.year, 6, 20));
    });

    testWidgets('cancelling the picker does not call onChanged',
        (tester) async {
      var calls = 0;
      await tester.pumpWidget(_wrap(DateField(
        label: 'Ship by',
        value: DateTime(DateTime.now().year, 6, 15),
        onChanged: (_) => calls++,
      )));
      await tester.tap(find.byType(DateField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls, 0);
    });
  });

  group('DateField without a date', () {
    testWidgets('shows the placeholder and still picks a date', (tester) async {
      DateTime? picked;
      await tester.pumpWidget(_wrap(DateField(
        label: 'Event date',
        value: null,
        onChanged: (d) => picked = d,
      )));
      expect(find.text('Not set'), findsOneWidget);
      await tester.tap(find.byType(DateField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(picked, isNotNull);
    });

    testWidgets('a set date with onCleared shows a clear button',
        (tester) async {
      var cleared = 0;
      await tester.pumpWidget(_wrap(DateField(
        label: 'Event date',
        value: DateTime(DateTime.now().year, 6, 15),
        onChanged: (_) {},
        onCleared: () => cleared++,
      )));
      expect(find.byIcon(Icons.event_rounded), findsNothing);
      await tester.tap(find.byTooltip('Clear Event date'));
      expect(cleared, 1);
    });

    testWidgets('no clear button while empty', (tester) async {
      await tester.pumpWidget(_wrap(DateField(
        label: 'Event date',
        value: null,
        onChanged: (_) {},
        onCleared: () {},
      )));
      expect(find.byTooltip('Clear Event date'), findsNothing);
      expect(find.byIcon(Icons.event_rounded), findsOneWidget);
    });
  });

  group('AppSearchField', () {
    testWidgets('shows hint and no clear button when empty', (tester) async {
      await tester.pumpWidget(
          _wrap(AppSearchField(hint: 'Search orders', onChanged: (_) {})));
      expect(find.text('Search orders'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('typing calls onChanged and shows clear, which clears',
        (tester) async {
      final values = <String>[];
      await tester.pumpWidget(
          _wrap(AppSearchField(hint: 'Search', onChanged: values.add)));
      await tester.enterText(find.byType(TextField), 'tulip');
      await tester.pump();
      expect(values.last, 'tulip');
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(values.last, '');
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
          '');
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('uses an external controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(AppSearchField(
        hint: 'Search',
        onChanged: (_) {},
        controller: controller,
      )));
      await tester.enterText(find.byType(TextField), 'bead');
      expect(controller.text, 'bead');
    });
  });

  group('CurrencyText', () {
    testWidgets('negative amounts use the minus sign', (tester) async {
      await tester.pumpWidget(_wrap(const CurrencyText(amount: -50)));
      expect(find.text('−₱50.00'), findsOneWidget);
    });

    testWidgets('short drops .00 on whole amounts', (tester) async {
      await tester
          .pumpWidget(_wrap(const CurrencyText(amount: 1200, short: true)));
      expect(find.text('₱1,200'), findsOneWidget);
    });

    testWidgets('short keeps real centavos', (tester) async {
      await tester
          .pumpWidget(_wrap(const CurrencyText(amount: 12.5, short: true)));
      expect(find.text('₱12.50'), findsOneWidget);
    });

    testWidgets('signed adds + to positive amounts', (tester) async {
      await tester
          .pumpWidget(_wrap(const CurrencyText(amount: 25, signed: true)));
      expect(find.text('+₱25.00'), findsOneWidget);
    });

    testWidgets('signed zero has no sign', (tester) async {
      await tester
          .pumpWidget(_wrap(const CurrencyText(amount: 0, signed: true)));
      expect(find.text('₱0.00'), findsOneWidget);
    });

    testWidgets('showSymbol false drops the peso sign', (tester) async {
      await tester
          .pumpWidget(_wrap(const CurrencyText(amount: -8, showSymbol: false)));
      expect(find.text('−8.00'), findsOneWidget);
    });

    testWidgets('compact shortens thousands', (tester) async {
      await tester
          .pumpWidget(_wrap(const CurrencyText(amount: -12500, compact: true)));
      expect(find.text('−₱12.5K'), findsOneWidget);
    });
  });
}
