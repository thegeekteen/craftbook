import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/widgets/app_card.dart';
import 'package:craftbook/features/debug/domain/repositories/shop_data_repository.dart';
import 'package:craftbook/features/debug/domain/usecases/seed_fake_shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/app_harness.dart';

void main() {
  /// The row totals straight from the database, to check what the page prints.
  Future<int> liveRowCount() async =>
      ok(await getIt<ShopDataRepository>().tableCounts())
          .values
          .fold<int>(0, (sum, count) => sum + count);

  testWidgets('the database page shows the schema, the coverage and the tables',
      (tester) async {
    await startApp(tester, seed: () async => ok(await getIt<SeedFakeShop>()()));
    await openApp(tester, RouteNames.debugDatabase);
    await settle(tester);

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Database & coverage'),
      ),
      findsOneWidget,
    );

    final thisDatabase =
        find.ancestor(of: find.text('Schema'), matching: find.byType(CardRow));
    expect(thisDatabase, findsOneWidget);
    expect(
      find.descendant(of: thisDatabase, matching: find.text('v12')),
      findsOneWidget,
    );

    final rows = await db<int>(tester, liveRowCount);
    expect(rows, greaterThan(0));
    final rowBoard =
        find.ancestor(of: find.text('Rows'), matching: find.byType(CardRow));
    expect(rowBoard, findsOneWidget);
    expect(find.descendant(of: rowBoard, matching: find.text('$rows')),
        findsOneWidget,
        reason: 'the row board must add up to the same database it lists');

    expect(find.text('COVERAGE'), findsOneWidget);
    expect(find.text('Every option the app offers showed up somewhere.'),
        findsOneWidget);

    await tester.scrollUntilVisible(find.text('TABLES'), 200,
        scrollable: find.byType(Scrollable).first);
    await settle(tester);
    expect(find.text('bom_items'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('an untouched database says what the data never exercised',
      (tester) async {
    await startApp(tester);
    await openApp(tester, RouteNames.debugDatabase);
    await settle(tester);

    expect(find.textContaining('Not everything was exercised'), findsOneWidget);
    expect(find.text('Every option the app offers showed up somewhere.'),
        findsNothing);
    await closeApp(tester);
  });
}
