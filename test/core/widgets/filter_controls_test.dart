import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/widgets/choice_chip_row.dart';
import 'package:craftbook/core/widgets/filter_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/localized_app.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    localizedApp(Scaffold(body: child), theme: AppTheme.lightTheme));

void main() {
  group('FilterButton', () {
    testWidgets('hides the badge with nothing on', (tester) async {
      await _pump(tester, FilterButton(activeCount: 0, onPressed: () {}));
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
    });

    testWidgets('shows how many filters are on and opens', (tester) async {
      var taps = 0;
      await _pump(
          tester, FilterButton(activeCount: 2, onPressed: () => taps++));
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.byTooltip('Filter'));
      expect(taps, 1);
    });
  });

  group('ActiveFilterChips', () {
    testWidgets('renders nothing with no filters', (tester) async {
      await _pump(tester, const ActiveFilterChips(filters: []));
      expect(find.byType(AppChip), findsNothing);
    });

    testWidgets('a chip removes its own filter; Clear needs two',
        (tester) async {
      final removed = <String>[];
      var cleared = 0;
      await _pump(
        tester,
        ActiveFilterChips(
          filters: [('Low', () => removed.add('Low'))],
          onClearAll: () => cleared++,
        ),
      );
      expect(find.text('Clear'), findsNothing);
      await tester.tap(find.widgetWithText(AppChip, 'Low'));
      expect(removed, ['Low']);

      await _pump(
        tester,
        ActiveFilterChips(
          filters: [('Low', () {}), ('Resell', () {})],
          onClearAll: () => cleared++,
        ),
      );
      await tester.tap(find.text('Clear'));
      expect(cleared, 1);
    });
  });
}
