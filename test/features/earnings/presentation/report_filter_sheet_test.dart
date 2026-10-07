import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/earnings/domain/entities/report_filter.dart';
import 'package:craftbook/features/earnings/presentation/widgets/report_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/localized_app.dart';

void main() {
  Future<ReportFilter?> run(WidgetTester tester, ReportFilter current,
      Future<void> Function() interact,
      {Locale locale = const Locale('en')}) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    ReportFilter? result;
    await tester.pumpWidget(localizedApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showReportFilterSheet(
            context,
            current: current,
            channels: const [(id: 1, name: 'Shopee'), (id: 2, name: 'Walk-in')],
            products: const [(id: 5, name: 'Tulip')],
          ),
          child: const Text('open'),
        ),
      ),
      theme: AppTheme.lightTheme,
      locale: locale,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await interact();
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('shows Filipino labels', (tester) async {
    await run(tester, ReportFilter.none, () async {
      expect(find.text('Hindi pa bayad'), findsOneWidget);
      expect(find.text('May diskwento'), findsOneWidget);
      expect(find.text('Unpaid'), findsNothing);
    }, locale: const Locale('fil'));
  });

  testWidgets('picks channels, payment and a minimum', (tester) async {
    final f = await run(tester, ReportFilter.none, () async {
      await tester.tap(find.text('Walk-in'));
      await tester.tap(find.text('Unpaid'));
      await tester.tap(find.text('With discount'));
      await tester.enterText(find.widgetWithText(TextField, 'From'), '200');
      await tester.tap(find.text('Show'));
    });
    expect(
        f,
        const ReportFilter(
          channelIds: {2},
          payment: PaymentFilter.unpaid,
          discount: Presence.with_,
          minTotal: 200,
        ));
  });

  testWidgets('tapping a chosen chip again lets it go', (tester) async {
    final f = await run(tester, const ReportFilter(productIds: {5}), () async {
      await tester.tap(find.text('Tulip'));
      await tester.tap(find.text('Show'));
    });
    expect(f, ReportFilter.none);
  });

  testWidgets('Clear all empties it', (tester) async {
    final f = await run(tester,
        const ReportFilter(channelIds: {1}, tax: Presence.without, maxTotal: 9),
        () async {
      await tester.tap(find.text('Clear all'));
      await tester.tap(find.text('Show'));
    });
    expect(f, ReportFilter.none);
  });
}
