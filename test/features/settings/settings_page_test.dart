import 'dart:io';

import 'package:craftbook/app.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/services/backup_store.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/sqlite.dart';

void main() {
  setUpAll(useHostSqlite);

  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('settings_page_');
  });
  tearDown(() => dir.delete(recursive: true));

  Future<void> boot(WidgetTester tester) async {
    // Phone-sized, so "Your data" is built without scrolling.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await getIt.reset();
      await configureDependencies(database: AppDatabase.forTesting(NativeDatabase.memory()));
      getIt.unregister<BackupStore>();
      getIt.registerSingleton(BackupStore(dataDir: () async => dir, scratchDir: () async => dir));
    });
    await tester.pumpWidget(CraftbookApp(initialLocation: RouteNames.settings));
    await _settle(tester);
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  }

  testWidgets('hides "Undo last restore" when nothing was restored', (tester) async {
    await boot(tester);
    expect(find.text('Restore from backup'), findsOneWidget);
    expect(find.text('Undo last restore'), findsNothing);
    await teardown(tester);
  });

  testWidgets('lists order fields under Catalogue', (tester) async {
    await boot(tester);
    expect(find.text('Order fields'), findsOneWidget);
    expect(find.text('Extra details to note on each order'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('offers "Undo last restore" after a restore', (tester) async {
    File('${dir.path}/craftbook.pre-restore.sqlite').writeAsStringSync('old data');
    await boot(tester);
    expect(find.text('Undo last restore'), findsOneWidget);
    await teardown(tester);
  });
}

/// Lets real database and file futures finish, then draws frames.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
