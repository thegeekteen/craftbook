import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/theme/colors.dart';
import 'package:craftbook/core/widgets/pip_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/localized_app.dart';

Widget _wrap(Widget child) =>
    localizedApp(Scaffold(body: child), theme: AppTheme.lightTheme);

/// Pip counts by kind, read from the Containers the strip draws.
class _Pips {
  int free = 0;
  int promised = 0;
  int incoming = 0;
  int removed = 0;
  int empty = 0;
  int markers = 0;

  int get pips => free + promised + incoming + removed + empty;
}

_Pips _countPips(WidgetTester tester, {PipSize size = PipSize.small}) {
  final w = size == PipSize.large ? 8.0 : 6.0;
  final h = size == PipSize.large ? 16.0 : 11.0;
  const colors = CraftColors.light;
  final out = _Pips();
  final containers = tester.widgetList<Container>(
    find.descendant(
        of: find.byType(PipStrip), matching: find.byType(Container)),
  );
  for (final ct in containers) {
    final d = ct.decoration;
    if (d is! BoxDecoration) continue;
    if (ct.constraints == BoxConstraints.tightFor(width: 2, height: h + 4)) {
      out.markers++;
      continue;
    }
    if (ct.constraints != BoxConstraints.tightFor(width: w, height: h)) {
      continue;
    }
    if (d.gradient != null) {
      out.promised++;
    } else if (d.border != null) {
      if ((d.border! as Border).top.width == 1.5) {
        out.incoming++;
      } else {
        out.removed++;
      }
    } else if (d.color == colors.pipEmpty) {
      out.empty++;
    } else {
      out.free++;
    }
  }
  return out;
}

void main() {
  group('PipStrip', () {
    testWidgets('draws free, promised and empty pips', (tester) async {
      await tester
          .pumpWidget(_wrap(const PipStrip(total: 10, free: 6, promised: 2)));
      final p = _countPips(tester);
      expect(p.free, 6);
      expect(p.promised, 2);
      // total 10, 8 filled -> 2 empty
      expect(p.empty, 2);
      expect(p.markers, 0);
    });

    testWidgets('pads with empty pips up to the alert level and marks it',
        (tester) async {
      await tester.pumpWidget(_wrap(const PipStrip(
        total: 3,
        free: 3,
        promised: 0,
        alertLevel: 8,
      )));
      final p = _countPips(tester);
      expect(p.free, 3);
      expect(p.empty, 5);
      expect(p.markers, 1);
    });

    testWidgets('alert marker present when alert level is within total',
        (tester) async {
      await tester.pumpWidget(_wrap(const PipStrip(
        total: 10,
        free: 10,
        promised: 0,
        alertLevel: 4,
      )));
      expect(_countPips(tester).markers, 1);
    });

    testWidgets('marker drawn after the last pip when alert level equals pips',
        (tester) async {
      await tester.pumpWidget(_wrap(const PipStrip(
        total: 5,
        free: 5,
        promised: 0,
        alertLevel: 5,
      )));
      final p = _countPips(tester);
      expect(p.pips, 5);
      expect(p.markers, 1);
    });

    testWidgets('no marker when alert level is zero', (tester) async {
      await tester
          .pumpWidget(_wrap(const PipStrip(total: 5, free: 5, promised: 0)));
      expect(_countPips(tester).markers, 0);
    });

    testWidgets('promised pips are capped at pieces physically available',
        (tester) async {
      await tester
          .pumpWidget(_wrap(const PipStrip(total: 7, free: 0, promised: 15)));
      final p = _countPips(tester);
      expect(p.free, 0);
      expect(p.promised, 7);
      expect(p.empty, 0);
    });

    testWidgets('negative free (overcommitted) is treated as zero',
        (tester) async {
      await tester
          .pumpWidget(_wrap(const PipStrip(total: 4, free: -3, promised: 7)));
      final p = _countPips(tester);
      expect(p.free, 0);
      expect(p.promised, 4);
    });

    testWidgets('large counts are scaled to at most maxPips', (tester) async {
      await tester.pumpWidget(_wrap(const SingleChildScrollView(
        child: PipStrip(total: 300, free: 200, promised: 100),
      )));
      final p = _countPips(tester);
      expect(p.pips, lessThanOrEqualTo(60));
      // 5 pieces per pip
      expect(p.free, 40);
      expect(p.promised, 20);
    });

    testWidgets('custom maxPips is honoured', (tester) async {
      await tester.pumpWidget(_wrap(const PipStrip(
        total: 100,
        free: 100,
        promised: 0,
        maxPips: 20,
      )));
      final p = _countPips(tester);
      expect(p.pips, lessThanOrEqualTo(20));
      expect(p.free, 20);
    });

    testWidgets('draws incoming pips for receive previews', (tester) async {
      await tester.pumpWidget(_wrap(const PipStrip(
        total: 8,
        free: 5,
        promised: 0,
        incoming: 3,
      )));
      final p = _countPips(tester);
      expect(p.free, 5);
      expect(p.incoming, 3);
      expect(p.empty, 0);
    });

    testWidgets('draws removed pips for pack previews', (tester) async {
      await tester.pumpWidget(_wrap(const PipStrip(
        total: 10,
        free: 6,
        promised: 0,
        removed: 4,
      )));
      final p = _countPips(tester);
      expect(p.free, 6);
      expect(p.removed, 4);
      expect(p.empty, 0);
    });

    testWidgets('large size uses bigger pips', (tester) async {
      await tester.pumpWidget(_wrap(const PipStrip(
        total: 4,
        free: 2,
        promised: 1,
        size: PipSize.large,
      )));
      final p = _countPips(tester, size: PipSize.large);
      expect(p.free, 2);
      expect(p.promised, 1);
      expect(p.empty, 1);
    });

    testWidgets('low stock paints free pips in the alert colour',
        (tester) async {
      await tester.pumpWidget(_wrap(const PipStrip(
        total: 2,
        free: 2,
        promised: 0,
        isLow: true,
      )));
      final alertPips = find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color == CraftColors.light.alert &&
          w.constraints == const BoxConstraints.tightFor(width: 6, height: 11));
      expect(alertPips, findsNWidgets(2));
    });

    testWidgets('semantics label summarises free and promised', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const PipStrip(
        total: 10,
        free: 6,
        promised: 2,
        alertLevel: 3,
      )));
      expect(
        find.bySemanticsLabel('6 free, 2 promised, reorder at 3'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('zero total renders nothing but does not throw',
        (tester) async {
      await tester
          .pumpWidget(_wrap(const PipStrip(total: 0, free: 0, promised: 0)));
      expect(tester.takeException(), isNull);
      expect(_countPips(tester).pips, 0);
    });
  });

  group('PipLegend', () {
    testWidgets('shows all keys by default', (tester) async {
      await tester.pumpWidget(_wrap(const PipLegend()));
      expect(find.text('free'), findsOneWidget);
      expect(find.text('promised'), findsOneWidget);
      expect(find.text('reorder level'), findsOneWidget);
    });

    testWidgets('hides optional keys', (tester) async {
      await tester.pumpWidget(
          _wrap(const PipLegend(showPromised: false, showAlert: false)));
      expect(find.text('free'), findsOneWidget);
      expect(find.text('promised'), findsNothing);
      expect(find.text('reorder level'), findsNothing);
    });
  });
}
