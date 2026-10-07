import 'package:craftbook/app.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/services/link_launcher.dart';
import 'package:craftbook/database/app_database.dart' show AppDatabase;
import 'package:craftbook/features/social_links/domain/entities/social_link.dart';
import 'package:craftbook/features/social_links/domain/repositories/social_link_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLauncher implements LinkLauncher {
  final opened = <String>[];
  bool succeeds = true;

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return succeeds;
  }
}

T _ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Social shortcuts end to end: the More row, the grid, the sheet.
void main() {
  late FakeLauncher launcher;

  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    launcher = FakeLauncher();
    await tester.runAsync(() async {
      await getIt.reset();
      await configureDependencies(
          database: AppDatabase.forTesting(NativeDatabase.memory()));
    });
    getIt.unregister<LinkLauncher>();
    getIt.registerSingleton<LinkLauncher>(launcher);
  }

  Future<void> open(WidgetTester tester, String location) async {
    await tester.pumpWidget(CraftbookApp(initialLocation: location));
    await _settle(tester);
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  }

  Future<void> seed(WidgetTester tester, List<SocialLink> links) async {
    await tester.runAsync(() async {
      for (final link in links) {
        _ok(await getIt<SocialLinkRepository>().createLink(link));
      }
    });
  }

  const facebook = SocialLink(
      platform: 'facebook',
      label: 'Facebook',
      url: 'https://facebook.com/mycrafts');
  const shopee = SocialLink(
      platform: 'shopee', label: 'Shopee', url: 'https://shopee.ph/mycrafts');

  testWidgets('More has a row that opens the page', (tester) async {
    await start(tester);
    await open(tester, RouteNames.settings);
    await tester.scrollUntilVisible(find.text('Social shortcuts'), 200,
        scrollable: find.byType(Scrollable).first);

    expect(find.text('Social shortcuts'), findsOneWidget);
    expect(find.text('Facebook, TikTok, Shopee, Lazada…'), findsOneWidget);
    await tester.tap(find.text('Social shortcuts'));
    await _settle(tester);

    expect(find.text('No shortcuts yet'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('the More row counts the shortcuts', (tester) async {
    await start(tester);
    await seed(tester, [facebook, shopee]);
    await open(tester, RouteNames.settings);
    await tester.scrollUntilVisible(
        find.text('2 shortcuts · Facebook, Shopee'), 200,
        scrollable: find.byType(Scrollable).first);

    expect(find.text('2 shortcuts · Facebook, Shopee'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('adds a preset shortcut with just a link', (tester) async {
    await start(tester);
    await open(tester, RouteNames.socialLinks);

    await tester.tap(find.text('Add shortcut'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TikTok'));
    await tester.pump();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Link'), 'tiktok.com/@mycrafts');
    await tester.tap(find.widgetWithText(FilledButton, 'Add shortcut'));
    await _settle(tester);

    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('tiktok.com/@mycrafts'), findsOneWidget);
    expect(find.text('TikTok added'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('a bad link is refused in the sheet', (tester) async {
    await start(tester);
    await open(tester, RouteNames.socialLinks);

    await tester.tap(find.text('Add shortcut'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Link'), 'not a link');
    await tester.tap(find.widgetWithText(FilledButton, 'Add shortcut'));
    await tester.pump();

    expect(find.textContaining('Enter a web address'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('a custom shortcut asks for a name and a colour', (tester) async {
    await start(tester);
    await open(tester, RouteNames.socialLinks);

    await tester.tap(find.text('Add shortcut'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other'));
    await tester.pump();
    expect(find.text('COLOUR'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Link'), 'blog.example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Add shortcut'));
    await tester.pump();
    expect(find.text('Enter a name'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'), 'My blog');
    await tester.tap(find.widgetWithText(FilledButton, 'Add shortcut'));
    await _settle(tester);

    expect(find.text('My blog'), findsWidgets);
    expect(find.text('blog.example.com'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('tapping a tile opens its link', (tester) async {
    await start(tester);
    await seed(tester, [facebook, shopee]);
    await open(tester, RouteNames.socialLinks);

    await tester.tap(find.text('Shopee'));
    await _settle(tester);

    expect(launcher.opened, ['https://shopee.ph/mycrafts']);
    await teardown(tester);
  });

  testWidgets('says so when a link cannot be opened', (tester) async {
    await start(tester);
    await seed(tester, [facebook]);
    await open(tester, RouteNames.socialLinks);
    launcher.succeeds = false;

    await tester.tap(find.text('Facebook'));
    await _settle(tester);

    expect(
        find.text('Couldn’t open Facebook. Check the link.'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('edits and removes a shortcut from edit mode', (tester) async {
    await start(tester);
    await seed(tester, [facebook, shopee]);
    await open(tester, RouteNames.socialLinks);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.drag_indicator_rounded), findsNWidgets(2));

    await tester.tap(find.text('Shopee'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Link'), 'shopee.ph/newname');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);
    expect(find.text('shopee.ph/newname'), findsOneWidget);

    await tester.tap(find.text('Shopee'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Shopee?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await _settle(tester);

    expect(find.text('shopee.ph/newname'), findsNothing);
    expect(find.text('Facebook'), findsOneWidget);
    await teardown(tester);
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
