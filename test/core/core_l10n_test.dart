import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/utils/date_utils.dart' as app_date;
import 'package:craftbook/core/widgets/confirm_dialog.dart';
import 'package:craftbook/core/widgets/filter_controls.dart';
import 'package:craftbook/core/widgets/pip_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../support/localized_app.dart';

void main() {
  tearDown(() => Intl.defaultLocale = null);

  testWidgets('shared widgets speak Filipino', (tester) async {
    await tester.pumpWidget(localizedApp(
      const Scaffold(
        body: Column(
            children: [PipLegend(), ConfirmDialog(title: 't', message: 'm')]),
      ),
      locale: const Locale('fil'),
      theme: AppTheme.lightTheme,
    ));
    expect(find.text('libre'), findsOneWidget);
    expect(find.text('Kanselahin'), findsOneWidget);
    expect(find.text('Kumpirmahin'), findsOneWidget);
  });

  testWidgets('filter button tooltip is translated', (tester) async {
    await tester.pumpWidget(localizedApp(
      FilterButton(activeCount: 0, onPressed: () {}),
      locale: const Locale('fil'),
    ));
    expect(find.byTooltip('I-filter'), findsOneWidget);
  });

  test('friendly dates follow the app language', () {
    final now = DateTime(2026, 5, 10);
    Intl.defaultLocale = 'fil';
    expect(app_date.DateUtils.friendly(now, now: now), 'Ngayon');
    expect(
        app_date.DateUtils.friendly(DateTime(2026, 5, 11), now: now), 'Bukas');
    Intl.defaultLocale = 'en';
    expect(app_date.DateUtils.friendly(now, now: now), 'Today');
    expect(app_date.DateUtils.friendly(DateTime(2026, 5, 9), now: now),
        'Yesterday');
  });

  test('an unsupported language falls back to English', () {
    Intl.defaultLocale = 'de';
    final now = DateTime(2026, 5, 10);
    expect(app_date.DateUtils.friendly(now, now: now), 'Today');
  });
}
