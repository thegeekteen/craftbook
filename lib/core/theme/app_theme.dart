import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: 'IBMPlexSans',
      colorScheme: ColorScheme.light(
        primary: AppColors.success,
        secondary: AppColors.coin,
        error: AppColors.alert,
        surface: AppColors.paperHigh,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            fontFamily: 'SpaceGrotesk',
            color: AppColors.ink),
        headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpaceGrotesk',
            color: AppColors.ink),
        titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpaceGrotesk',
            color: AppColors.ink),
        titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSans',
            color: AppColors.ink),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'IBMPlexSans',
            color: AppColors.ink),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'IBMPlexSans',
            color: AppColors.ink),
        bodySmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: 'IBMPlexSans',
            color: AppColors.muted),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSans',
            color: AppColors.ink),
        labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexMono',
            letterSpacing: 0.1,
            color: AppColors.muted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.displaySmall.copyWith(
          color: AppColors.ink,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.paperHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.hair),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle:
              AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          minimumSize: const Size(0, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.hair),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: AppTextStyles.bodyMedium,
          minimumSize: const Size(0, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          textStyle: AppTextStyles.bodyMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hair),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hair),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.success, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: AppTextStyles.monoSection,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.hair,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.paperHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        titleTextStyle: AppTextStyles.displaySmall.copyWith(
          color: AppColors.ink,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paperHigh,
        selectedColor: AppColors.successSoft,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.ink,
        ),
        side: const BorderSide(color: AppColors.hair),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
