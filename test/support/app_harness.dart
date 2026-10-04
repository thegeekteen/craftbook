import 'package:craftbook/app.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unwraps a [Result] in test setup, where a failure is a broken test.
T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// A phone-sized screen and a fresh in-memory database; [seed] runs once
/// dependencies are registered.
Future<void> startApp(WidgetTester tester,
    {Future<void> Function()? seed}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.runAsync(() async {
    await getIt.reset();
    await configureDependencies(
        database: AppDatabase.forTesting(NativeDatabase.memory()));
    await seed?.call();
  });
}

Future<void> openApp(WidgetTester tester, String location) async {
  await tester.pumpWidget(CraftbookApp(initialLocation: location));
  await settle(tester);
}

Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(() => getIt<AppDatabase>().close());
}

/// Runs [body] against the real database, outside the fake clock.
///
/// Pass [T] explicitly (`db<Result<Order?>>(...)`) and unwrap into a typed
/// local: inferred from an async return type, T picks up `FutureOr` and the
/// result comes back wrong.
Future<T> db<T>(WidgetTester tester, Future<T> Function() body) async =>
    (await tester.runAsync(body)) as T;

/// Real database work runs outside the fake clock, so pump a fixed run of
/// frames instead of pumpAndSettle.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
