import 'package:flutter/material.dart';

import '../../../../core/theme/text_styles.dart';

/// The rounded tile that stands in for a site's logo: brand colour with a
/// letter or two. Brand colours are data, not theme colours, so they look the
/// same in light and dark.
class SocialMark extends StatelessWidget {
  /// ARGB brand colour.
  final int color;
  final String glyph;
  final double size;

  const SocialMark({
    super.key,
    required this.color,
    required this.glyph,
    this.size = 52,
  });

  /// Light text on dark brand colours, dark text on light ones.
  static Color foregroundFor(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF161616);
  }

  @override
  Widget build(BuildContext context) {
    final background = Color(color);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(background, const Color(0xFFFFFFFF), 0.14)!,
              background,
            ],
          ),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Text(
          glyph,
          maxLines: 1,
          style: AppTextStyles.displaySmall.copyWith(
            color: foregroundFor(background),
            fontSize: size * (glyph.length > 1 ? 0.36 : 0.46),
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
