import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/theme/palettes.dart';
import 'package:craftbook/core/utils/currency_setting.dart';
import 'package:craftbook/features/settings/presentation/widgets/currency_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<CurrencySetting?> open(
      WidgetTester tester, Future<void> Function() interact) async {
    CurrencySetting? picked;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(AppPalette.forest),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => picked =
              await showCurrencySheet(context, current: CurrencySetting.php),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await interact();
    await tester.pumpAndSettle();
    return picked;
  }

  testWidgets('lists the presets and marks the current one', (tester) async {
    await open(tester, () async {
      expect(find.text('Philippine peso'), findsOneWidget);
      expect(find.text('US dollar'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  testWidgets('tapping a preset returns it', (tester) async {
    final picked = await open(tester, () => tester.tap(find.text('US dollar')));
    expect(picked, CurrencySetting.preset('USD'));
  });

  testWidgets('a custom symbol can be used without cents', (tester) async {
    final picked = await open(tester, () async {
      await tester.scrollUntilVisible(find.text('No cents'), 200,
          scrollable: find.byType(Scrollable).last);
      await tester.enterText(find.byType(TextField), 'kr');
      await tester.tap(find.text('No cents'));
      await tester.pump();
      await tester.tap(find.text('Use'));
    });
    expect(
      picked,
      const CurrencySetting(
          code: CurrencySetting.customCode, symbol: 'kr', decimals: 0),
    );
  });
}
