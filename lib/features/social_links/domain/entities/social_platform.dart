/// A selling or social site with a ready-made look, so the common ones need
/// nothing but a link.
class SocialPlatform {
  /// Stored in the database; never change a key once shipped.
  final String key;
  final String name;

  /// ARGB brand colour of the tile.
  final int color;

  /// One or two letters drawn on the tile. No brand artwork is bundled.
  final String glyph;

  /// Shown as the URL field's hint.
  final String urlHint;

  const SocialPlatform({
    required this.key,
    required this.name,
    required this.color,
    required this.glyph,
    required this.urlHint,
  });

  /// Key of a link with its own name and colour.
  static const customKey = 'custom';

  static const facebook = SocialPlatform(
    key: 'facebook',
    name: 'Facebook',
    color: 0xFF1877F2,
    glyph: 'f',
    urlHint: 'facebook.com/yourshop',
  );
  static const instagram = SocialPlatform(
    key: 'instagram',
    name: 'Instagram',
    color: 0xFFD62976,
    glyph: 'ig',
    urlHint: 'instagram.com/yourshop',
  );
  static const tiktok = SocialPlatform(
    key: 'tiktok',
    name: 'TikTok',
    color: 0xFF161616,
    glyph: 'Tk',
    urlHint: 'tiktok.com/@yourshop',
  );
  static const shopee = SocialPlatform(
    key: 'shopee',
    name: 'Shopee',
    color: 0xFFEE4D2D,
    glyph: 'S',
    urlHint: 'shopee.ph/yourshop',
  );
  static const lazada = SocialPlatform(
    key: 'lazada',
    name: 'Lazada',
    color: 0xFF0F146D,
    glyph: 'L',
    urlHint: 'lazada.com.ph/shop/yourshop',
  );
  static const messenger = SocialPlatform(
    key: 'messenger',
    name: 'Messenger',
    color: 0xFF0A7CFF,
    glyph: 'M',
    urlHint: 'm.me/yourshop',
  );
  static const youtube = SocialPlatform(
    key: 'youtube',
    name: 'YouTube',
    color: 0xFFE62117,
    glyph: 'Yt',
    urlHint: 'youtube.com/@yourshop',
  );
  static const pinterest = SocialPlatform(
    key: 'pinterest',
    name: 'Pinterest',
    color: 0xFFE60023,
    glyph: 'P',
    urlHint: 'pinterest.com/yourshop',
  );
  static const etsy = SocialPlatform(
    key: 'etsy',
    name: 'Etsy',
    color: 0xFFF1641E,
    glyph: 'E',
    urlHint: 'etsy.com/shop/yourshop',
  );

  static const presets = [
    facebook,
    instagram,
    tiktok,
    shopee,
    lazada,
    messenger,
    youtube,
    pinterest,
    etsy,
  ];

  /// Colours offered for custom links.
  static const customColors = [
    0xFF2F6F5E,
    0xFF3B5BDB,
    0xFF7048E8,
    0xFFC2255C,
    0xFFE8590C,
    0xFFF59F00,
    0xFF1C7ED6,
    0xFF495057,
  ];

  /// The preset for [key], or null for `custom` and anything unknown.
  static SocialPlatform? byKey(String key) {
    for (final p in presets) {
      if (p.key == key) return p;
    }
    return null;
  }
}
