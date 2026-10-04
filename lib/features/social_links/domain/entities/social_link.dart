import 'package:equatable/equatable.dart';

import 'social_platform.dart';

/// One shortcut to the shop's page on a site.
class SocialLink extends Equatable {
  final int? id;

  /// A [SocialPlatform] key, or [SocialPlatform.customKey].
  final String platform;
  final String label;

  /// Always a full `https://` (or `http://`) address.
  final String url;

  /// ARGB tile colour; only used when the platform isn't a known preset.
  final int? colorValue;
  final int position;

  const SocialLink({
    this.id,
    required this.platform,
    required this.label,
    required this.url,
    this.colorValue,
    this.position = 0,
  });

  /// The preset this link looks like, if any.
  SocialPlatform? get preset => SocialPlatform.byKey(platform);

  /// Tile colour: the preset's brand colour, else the chosen one.
  int get tileColor =>
      preset?.color ?? colorValue ?? SocialPlatform.customColors.first;

  /// What the tile shows: the preset's mark, else the label's first letter.
  String get glyph {
    final preset = this.preset;
    if (preset != null) return preset.glyph;
    final trimmed = label.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  /// `facebook.com/yourshop` — the address without scheme, `www.` and any
  /// trailing slash, for a quiet second line under the label.
  String get displayUrl {
    var text = url.replaceFirst(RegExp(r'^https?://'), '');
    text = text.replaceFirst(RegExp(r'^www\.'), '');
    return text.endsWith('/') ? text.substring(0, text.length - 1) : text;
  }

  @override
  List<Object?> get props => [id, platform, label, url, colorValue, position];
}
