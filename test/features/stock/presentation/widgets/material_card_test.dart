import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/widgets/pip_strip.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart' as entity;
import 'package:craftbook/features/stock/presentation/widgets/material_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

entity.Material _material({
  int onHand = 10,
  int promised = 4,
  int alertLevel = 3,
  double unitCost = 2.5,
}) {
  final now = DateTime(2026, 1, 1);
  return entity.Material(
    id: 1,
    name: 'Glass beads',
    packSize: 100,
    packPrice: 250,
    unitCost: unitCost,
    quantityOnHand: onHand,
    quantityPromised: promised,
    alertLevel: alertLevel,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('MaterialCard', () {
    testWidgets('shows name, on hand, pips and summary', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(MaterialCard(
        material: _material(),
        onTap: () => taps++,
      )));
      expect(find.text('Glass beads'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('6 free · 4 promised · reorder at 3 · ₱2.50/pc'), findsOneWidget);
      expect(find.text('LOW'), findsNothing);
      final pips = tester.widget<PipStrip>(find.byType(PipStrip));
      expect(pips.total, 10);
      expect(pips.free, 6);
      expect(pips.promised, 4);
      expect(pips.alertLevel, 3);
      expect(pips.isLow, isFalse);
      await tester.tap(find.text('Glass beads'));
      expect(taps, 1);
    });

    testWidgets('omits promised when nothing is promised', (tester) async {
      await tester.pumpWidget(_wrap(MaterialCard(material: _material(promised: 0))));
      expect(find.text('10 free · reorder at 3 · ₱2.50/pc'), findsOneWidget);
    });

    testWidgets('low stock shows LOW tag', (tester) async {
      await tester.pumpWidget(_wrap(MaterialCard(
        material: _material(onHand: 2, promised: 0, alertLevel: 5),
      )));
      expect(find.text('LOW'), findsOneWidget);
      expect(tester.widget<PipStrip>(find.byType(PipStrip)).isLow, isTrue);
    });

    testWidgets('at the alert level counts as low', (tester) async {
      await tester.pumpWidget(_wrap(MaterialCard(
        material: _material(onHand: 3, promised: 0, alertLevel: 3),
      )));
      expect(find.text('LOW'), findsOneWidget);
    });

    testWidgets('promised beyond on hand shows N short and zero free', (tester) async {
      await tester.pumpWidget(_wrap(MaterialCard(
        material: _material(onHand: 8, promised: 11, alertLevel: 2),
      )));
      expect(
        find.text('0 free · 11 promised · reorder at 2 · ₱2.50/pc · 3 short'),
        findsOneWidget,
      );
      expect(find.text('LOW'), findsNothing);
    });

    testWidgets('no short text when fully covered', (tester) async {
      await tester.pumpWidget(_wrap(MaterialCard(material: _material(onHand: 5, promised: 5))));
      expect(find.textContaining('short'), findsNothing);
    });
  });
}
