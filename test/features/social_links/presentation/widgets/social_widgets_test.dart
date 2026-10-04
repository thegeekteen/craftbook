import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/social_links/domain/entities/social_link.dart';
import 'package:craftbook/features/social_links/presentation/widgets/social_link_tile.dart';
import 'package:craftbook/features/social_links/presentation/widgets/social_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
          body: Center(child: SizedBox(width: 180, height: 140, child: child))),
    );

void main() {
  group('SocialMark', () {
    testWidgets('draws the glyph', (tester) async {
      await tester
          .pumpWidget(host(const SocialMark(color: 0xFF1877F2, glyph: 'f')));
      expect(find.text('f'), findsOneWidget);
    });

    test('picks readable text for dark and light backgrounds', () {
      expect(SocialMark.foregroundFor(const Color(0xFF0F146D)),
          const Color(0xFFFFFFFF));
      expect(SocialMark.foregroundFor(const Color(0xFFF59F00)),
          const Color(0xFF161616));
    });
  });

  group('SocialLinkTile', () {
    const link = SocialLink(
      id: 1,
      platform: 'shopee',
      label: 'Shopee',
      url: 'https://www.shopee.ph/mycrafts/',
    );

    testWidgets('long press fires onLongPress, not onTap', (tester) async {
      var taps = 0;
      var longPresses = 0;
      await tester.pumpWidget(host(SocialLinkTile(
        link: link,
        onTap: () => taps++,
        onLongPress: () => longPresses++,
      )));
      await tester.longPress(find.text('Shopee'));
      expect((taps, longPresses), (0, 1));
    });

    testWidgets('shows the name and the tidy address', (tester) async {
      await tester.pumpWidget(host(SocialLinkTile(link: link, onTap: () {})));

      expect(find.text('Shopee'), findsOneWidget);
      expect(find.text('shopee.ph/mycrafts'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('is a button that opens the link', (tester) async {
      var taps = 0;
      await tester
          .pumpWidget(host(SocialLinkTile(link: link, onTap: () => taps++)));

      expect(find.bySemanticsLabel('Open Shopee'), findsOneWidget);
      await tester.tap(find.byType(SocialLinkTile));
      expect(taps, 1);
    });

    testWidgets('a long name is cut off rather than overflowing',
        (tester) async {
      const long = SocialLink(
        platform: 'custom',
        label: 'A really quite long shop name that keeps going and going',
        url: 'https://example.com/a/very/long/path/that/also/keeps/going',
      );
      await tester.pumpWidget(host(SocialLinkTile(link: long, onTap: () {})));

      expect(tester.takeException(), isNull);
    });
  });
}
