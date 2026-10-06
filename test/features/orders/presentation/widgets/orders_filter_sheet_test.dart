import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/orders/presentation/widgets/orders_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<OrderPaymentFilter?> run(WidgetTester tester,
      OrderPaymentFilter current, Future<void> Function() interact) async {
    OrderPaymentFilter? result;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showOrdersFilterSheet(
            context,
            current: current,
            unpaidCount: 3,
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await interact();
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('shows the options with the unpaid count', (tester) async {
    await run(tester, OrderPaymentFilter.any, () async {
      expect(find.text('Filter orders'), findsOneWidget);
      expect(find.text('Any'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Unpaid'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });

  testWidgets('picks Unpaid', (tester) async {
    final f = await run(tester, OrderPaymentFilter.any, () async {
      await tester.tap(find.text('Unpaid'));
      await tester.tap(find.text('Show'));
    });
    expect(f, OrderPaymentFilter.unpaid);
  });

  testWidgets('Clear all goes back to Any', (tester) async {
    final f = await run(tester, OrderPaymentFilter.paid, () async {
      await tester.tap(find.text('Clear all'));
      await tester.tap(find.text('Show'));
    });
    expect(f, OrderPaymentFilter.any);
  });
}
