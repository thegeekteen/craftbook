import 'package:flutter/painting.dart';

/// Type scale. Styles carry no colour so they work in both themes; colour
/// comes from the surrounding DefaultTextStyle or an explicit copyWith.
///
/// Letter spacing is in logical pixels (Flutter does not use em units).
class AppTextStyles {
  AppTextStyles._();

  static const String display = 'Bricolage';
  static const String body = 'IBMPlexSans';
  static const String mono = 'IBMPlexMono';

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Hero numbers: profit totals, on-hand counts.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: display,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.0,
    fontFeatures: _tabular,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: display,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.1,
    fontFeatures: _tabular,
  );

  /// App bar and sheet titles.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: display,
    fontSize: 21,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
  );

  /// Inline amounts and stat values.
  static const TextStyle amount = TextStyle(
    fontFamily: display,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.2,
    fontFeatures: _tabular,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: body,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Numbers inside body text that must line up in columns.
  static const TextStyle tabular = TextStyle(fontFeatures: _tabular);

  /// Uppercase section and stat labels.
  static const TextStyle monoLabel = TextStyle(
    fontFamily: mono,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.9,
    height: 1.3,
  );

  /// Pills and tags; the smallest text in the app.
  static const TextStyle monoTag = TextStyle(
    fontFamily: mono,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );
}
