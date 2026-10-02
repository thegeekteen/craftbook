import 'package:flutter/material.dart';
import 'colors.dart';

/// Typography system matching the UI mockup
class AppTextStyles {
  AppTextStyles._();

  // Display styles (Space Grotesk)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 52,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.03,
    height: 0.98,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 27,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.02,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.02,
  );

  // Body styles (IBM Plex Sans)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    height: 1.25,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    height: 1.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 10.5,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.muted,
  );

  // Mono styles (IBM Plex Mono)
  static const TextStyle monoLabel = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.02,
  );

  static const TextStyle monoSection = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.14,
    color: AppColors.muted,
  );
}
