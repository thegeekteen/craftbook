import 'package:craftbook/app.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/products/presentation/pages/channels_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/sqlite.dart';

void main() {
  setUpAll(useHostSqlite);

  testWidgets(
      '"Add channel" banner in the order wizard opens Channels without a duplicate-key crash',
      (tester) async {
    await tester.runAsync(() async {
      await getIt.reset();
      await configureDependencies(
          database: AppDatabase.forTesting(NativeDatabase.memory()));
    });
    await tester.pumpWidget(CraftbookApp(initialLocation: RouteNames.orders));
    await _settle(tester);

    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .push(RouteNames.newOrder);
    await _settle(tester);

    await tester.tap(find.text('Add'));
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(ChannelsPage), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
