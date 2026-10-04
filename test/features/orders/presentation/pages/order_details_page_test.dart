import 'package:craftbook/app.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/utils/currency_formatter.dart';
import 'package:craftbook/database/app_database.dart' hide Order;
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/presentation/widgets/order_status_ui.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/sample_data.dart';
import '../../../../support/sqlite.dart';

void main() {
  setUpAll(useHostSqlite);

  testWidgets('the order total is the headline and profit is the bottom line', (tester) async {
    // Tall enough to show the whole page without scrolling.
    tester.view.physicalSize = const Size(1080, 4800);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    late Order order;
    await tester.runAsync(() async {
      await getIt.reset();
      await configureDependencies(database: AppDatabase.forTesting(NativeDatabase.memory()));
      await seedSampleShop();
      order = (await getIt<OrderRepository>().getOrderById(8) as Success<Order?>).value!;
    });
    await tester.pumpWidget(CraftbookApp(initialLocation: RouteNames.orderPath(8)));
    await _settle(tester);

    final totalRow = find.ancestor(of: find.text('ORDER TOTAL'), matching: find.byType(Row));
    expect(
      find.descendant(of: totalRow, matching: find.text(CurrencyFormatter.format(order.totalSales))),
      findsOneWidget,
    );
    expect(find.text('PROFIT'), findsNothing);

    final profit = find.textContaining('Profit · ');
    expect(profit, findsOneWidget);
    expect(find.text(CurrencyFormatter.format(order.liveProfit)), findsOneWidget);
    expect(
      tester.getTopLeft(profit).dy,
      greaterThan(tester.getTopLeft(find.text('Shipping')).dy),
    );
    expect(
      tester.getTopLeft(find.text('ORDER TOTAL')).dy,
      lessThan(tester.getTopLeft(profit).dy),
    );

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
