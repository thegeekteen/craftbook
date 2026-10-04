import 'package:craftbook/features/social_links/domain/entities/social_link.dart';
import 'package:craftbook/features/social_links/domain/entities/social_platform.dart';
import 'package:craftbook/features/social_links/domain/social_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeSocialUrl', () {
    test('adds https when the scheme is missing', () {
      expect(normalizeSocialUrl('facebook.com/mycrafts'),
          'https://facebook.com/mycrafts');
    });

    test('keeps a scheme that is already there, and trims', () {
      expect(
          normalizeSocialUrl('  http://shopee.ph/x  '), 'http://shopee.ph/x');
      expect(normalizeSocialUrl('https://www.tiktok.com/@me'),
          'https://www.tiktok.com/@me');
    });

    test('refuses empty, spaced, hostless and non-web input', () {
      expect(normalizeSocialUrl(''), isNull);
      expect(normalizeSocialUrl('   '), isNull);
      expect(normalizeSocialUrl('my shop'), isNull);
      expect(normalizeSocialUrl('shopee'), isNull);
      expect(normalizeSocialUrl('https://abc'), isNull);
      expect(normalizeSocialUrl('javascript://alert(1)'), isNull);
      expect(normalizeSocialUrl('file:///etc/passwd'), isNull);
      expect(normalizeSocialUrl('ftp://files.example.com'), isNull);
    });
  });

  group('SocialPlatform', () {
    test('preset keys are unique and findable', () {
      final keys = SocialPlatform.presets.map((p) => p.key).toList();
      expect(keys.toSet(), hasLength(keys.length));
      for (final p in SocialPlatform.presets) {
        expect(SocialPlatform.byKey(p.key), same(p));
      }
    });

    test('custom and unknown keys have no preset', () {
      expect(SocialPlatform.byKey(SocialPlatform.customKey), isNull);
      expect(SocialPlatform.byKey('myspace'), isNull);
    });

    test('covers the sites the shop asked for', () {
      expect(
        SocialPlatform.presets.map((p) => p.key),
        containsAll(['facebook', 'tiktok', 'lazada', 'shopee']),
      );
    });
  });

  group('SocialLink', () {
    test('a preset link uses the brand colour and glyph', () {
      const link = SocialLink(
          platform: 'shopee',
          label: 'My Shopee',
          url: 'https://shopee.ph/x',
          colorValue: 1);
      expect(link.tileColor, SocialPlatform.shopee.color);
      expect(link.glyph, SocialPlatform.shopee.glyph);
    });

    test('a custom link uses its own colour and the label initial', () {
      const link = SocialLink(
          platform: 'custom',
          label: 'blog',
          url: 'https://a.com',
          colorValue: 0xFF123456);
      expect(link.tileColor, 0xFF123456);
      expect(link.glyph, 'B');
    });

    test('a custom link without a colour falls back to the first swatch', () {
      const link =
          SocialLink(platform: 'custom', label: '', url: 'https://a.com');
      expect(link.tileColor, SocialPlatform.customColors.first);
      expect(link.glyph, '?');
    });

    test('displayUrl drops scheme, www and trailing slash', () {
      const link = SocialLink(
          platform: 'custom',
          label: 'x',
          url: 'https://www.facebook.com/mycrafts/');
      expect(link.displayUrl, 'facebook.com/mycrafts');
    });
  });
}
