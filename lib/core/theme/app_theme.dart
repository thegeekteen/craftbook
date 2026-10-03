import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'dimens.dart';
import 'text_styles.dart';

/// Builds the light and dark themes from the same [CraftColors] tokens so
/// both stay in step.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(CraftColors.light, Brightness.light);
  static ThemeData get darkTheme => _build(CraftColors.dark, Brightness.dark);

  static ThemeData _build(CraftColors c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.go,
      onPrimary: c.onAccent,
      primaryContainer: c.goSoft,
      onPrimaryContainer: c.go,
      secondary: c.coin,
      onSecondary: c.onAccent,
      secondaryContainer: c.coinSoft,
      onSecondaryContainer: c.coin,
      tertiary: c.warn,
      onTertiary: c.onAccent,
      error: c.alert,
      onError: c.onAccent,
      errorContainer: c.alertSoft,
      onErrorContainer: c.alert,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.muted,
      surfaceContainerLowest: c.surface,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surface,
      surfaceContainerHighest: c.paper,
      outline: c.hair,
      outlineVariant: c.hair,
      shadow: c.shadow,
      scrim: c.scrim,
      inverseSurface: c.ink,
      onInverseSurface: c.paper,
    );

    final textTheme = TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: c.ink),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: c.ink),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: c.ink),
      headlineMedium: AppTextStyles.displayMedium.copyWith(color: c.ink),
      headlineSmall: AppTextStyles.displaySmall.copyWith(color: c.ink),
      titleLarge: AppTextStyles.displaySmall.copyWith(color: c.ink),
      titleMedium: AppTextStyles.bodyLarge.copyWith(color: c.ink),
      titleSmall: AppTextStyles.bodyMedium
          .copyWith(color: c.ink, fontWeight: FontWeight.w600),
      bodyLarge: AppTextStyles.bodyLarge
          .copyWith(color: c.ink, fontWeight: FontWeight.w400),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: c.ink),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: c.muted),
      labelLarge: AppTextStyles.bodyMedium
          .copyWith(color: c.ink, fontWeight: FontWeight.w600),
      labelMedium: AppTextStyles.bodySmall
          .copyWith(color: c.ink, fontWeight: FontWeight.w500),
      labelSmall: AppTextStyles.monoLabel.copyWith(color: c.muted),
    );

    final controlShape =
        const RoundedRectangleBorder(borderRadius: AppRadii.controlAll);
    final buttonText = AppTextStyles.bodyMedium
        .copyWith(fontWeight: FontWeight.w600, fontSize: 14.5);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadii.controlAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [c],
      scaffoldBackgroundColor: c.paper,
      canvasColor: c.paper,
      fontFamily: AppTextStyles.body,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: c.hair,
      appBarTheme: AppBarTheme(
        backgroundColor: c.paper,
        foregroundColor: c.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.gutter,
        titleTextStyle: AppTextStyles.displaySmall.copyWith(color: c.ink),
        iconTheme: IconThemeData(color: c.ink, size: 22),
        actionsIconTheme: IconThemeData(color: c.ink, size: 22),
        systemOverlayStyle: (isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardAll,
          side: BorderSide(color: c.hair),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.go,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.hair,
          disabledForegroundColor: c.muted,
          elevation: 0,
          shape: controlShape,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: buttonText,
          minimumSize: const Size(0, 48),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.go,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.hair,
          disabledForegroundColor: c.muted,
          shape: controlShape,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: buttonText,
          minimumSize: const Size(0, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          backgroundColor: c.surface,
          side: BorderSide(color: c.hair),
          shape: controlShape,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: buttonText,
          minimumSize: const Size(0, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.go,
          shape: controlShape,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          textStyle: buttonText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        border: inputBorder(c.hair),
        enabledBorder: inputBorder(c.hair),
        focusedBorder: inputBorder(c.go, 2),
        errorBorder: inputBorder(c.alert),
        focusedErrorBorder: inputBorder(c.alert, 2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: c.muted),
        floatingLabelStyle: AppTextStyles.bodyMedium
            .copyWith(color: c.go, fontWeight: FontWeight.w500),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: c.muted),
        helperStyle: AppTextStyles.bodySmall.copyWith(color: c.muted),
        prefixStyle: AppTextStyles.bodyMedium.copyWith(color: c.muted),
        suffixStyle: AppTextStyles.bodyMedium.copyWith(color: c.muted),
        prefixIconColor: c.muted,
        suffixIconColor: c.muted,
      ),
      dividerTheme: DividerThemeData(color: c.hair, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sheet),
        ),
        titleTextStyle: AppTextStyles.displaySmall.copyWith(color: c.ink),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: c.muted),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        showDragHandle: true,
        dragHandleColor: c.hair,
        dragHandleSize: const Size(36, 4),
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.ink,
        disabledColor: c.paper,
        labelStyle: AppTextStyles.bodySmall
            .copyWith(color: c.ink, fontWeight: FontWeight.w500, fontSize: 13),
        secondaryLabelStyle: AppTextStyles.bodySmall
            .copyWith(color: c.paper, fontWeight: FontWeight.w600, fontSize: 13),
        side: BorderSide(color: c.hair),
        shape: const StadiumBorder(),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.muted,
          selectedBackgroundColor: c.ink,
          selectedForegroundColor: c.paper,
          side: BorderSide(color: c.hair),
          textStyle: buttonText.copyWith(fontSize: 13),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onAccent : c.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.go : c.hair,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.go,
        foregroundColor: c.onAccent,
        elevation: 3,
        highlightElevation: 5,
        extendedTextStyle: buttonText,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: c.goSoft,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected) ? c.go : c.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: s.contains(WidgetState.selected) ? c.ink : c.muted,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.ink,
        unselectedLabelColor: c.muted,
        indicatorColor: c.go,
        dividerColor: c.hair,
        labelStyle: buttonText.copyWith(fontSize: 13.5),
        unselectedLabelStyle: buttonText.copyWith(
            fontSize: 13.5, fontWeight: FontWeight.w500),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.ink,
        textColor: c.ink,
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(color: c.ink),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(color: c.muted),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.controlAll),
        textStyle: AppTextStyles.bodyMedium.copyWith(color: c.ink),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: c.board,
        headerForegroundColor: c.boardInk,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sheet),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.go,
        linearTrackColor: c.hair,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: c.paper),
        actionTextColor: c.goSoft,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.controlAll),
      ),
    );
  }
}
