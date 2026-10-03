import 'package:flutter/material.dart';

/// Light palette as compile-time constants.
///
/// Widgets should read colours through `context.colors` so they follow the
/// active theme; these constants exist for theme construction and tests.
class AppColors {
  AppColors._();

  static const Color board = Color(0xFF15191B);
  static const Color ink = Color(0xFF121917);
  static const Color paper = Color(0xFFF4F5F1);
  static const Color paperHigh = Color(0xFFFFFFFF);
  static const Color hair = Color(0xFFDFE2DA);
  static const Color muted = Color(0xFF69716C);

  static const Color success = Color(0xFF1F6F5C);
  static const Color successSoft = Color(0xFFDCEBE4);
  static const Color alert = Color(0xFFB93B22);
  static const Color alertSoft = Color(0xFFF6E1DA);
  // Darker than the original amber so it passes contrast on white.
  static const Color warning = Color(0xFFA86D12);
  static const Color warningSoft = Color(0xFFF7ECD6);
  static const Color coin = Color(0xFF4B4C8A);
  static const Color coinSoft = Color(0xFFE4E4F2);

  static const Color pipEmpty = Color(0xFFDCE0D8);
}

/// Semantic colour tokens for the active theme.
///
/// Meaning is fixed across themes: [go] is profit/free stock/primary action,
/// [alert] is cost/low stock/destructive, [warn] is fees/to-pack,
/// [coin] is money totals/shipped.
@immutable
class CraftColors extends ThemeExtension<CraftColors> {
  final Color paper;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color hair;
  final Color go;
  final Color goSoft;
  final Color alert;
  final Color alertSoft;
  final Color warn;
  final Color warnSoft;
  final Color coin;
  final Color coinSoft;

  /// Text/icons drawn on top of [go], [alert] or [coin] fills.
  final Color onAccent;

  /// Dark summary panel used on Today and Money.
  final Color board;
  final Color boardRaised;
  final Color boardInk;
  final Color boardMuted;

  final Color pipEmpty;
  final Color scrim;
  final Color shadow;

  const CraftColors({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.hair,
    required this.go,
    required this.goSoft,
    required this.alert,
    required this.alertSoft,
    required this.warn,
    required this.warnSoft,
    required this.coin,
    required this.coinSoft,
    required this.onAccent,
    required this.board,
    required this.boardRaised,
    required this.boardInk,
    required this.boardMuted,
    required this.pipEmpty,
    required this.scrim,
    required this.shadow,
  });

  static const light = CraftColors(
    paper: AppColors.paper,
    surface: AppColors.paperHigh,
    ink: AppColors.ink,
    muted: AppColors.muted,
    hair: AppColors.hair,
    go: AppColors.success,
    goSoft: AppColors.successSoft,
    alert: AppColors.alert,
    alertSoft: AppColors.alertSoft,
    warn: AppColors.warning,
    warnSoft: AppColors.warningSoft,
    coin: AppColors.coin,
    coinSoft: AppColors.coinSoft,
    onAccent: Color(0xFFFFFFFF),
    board: AppColors.board,
    boardRaised: Color(0xFF262D30),
    boardInk: Color(0xFFF1F3EE),
    boardMuted: Color(0xFF9AA39E),
    pipEmpty: AppColors.pipEmpty,
    scrim: Color(0x730A0D0C),
    shadow: Color(0x14000000),
  );

  static const dark = CraftColors(
    paper: Color(0xFF101514),
    surface: Color(0xFF181E1C),
    ink: Color(0xFFE8EBE5),
    muted: Color(0xFF909893),
    hair: Color(0xFF29302E),
    go: Color(0xFF4FB394),
    goSoft: Color(0xFF173229),
    alert: Color(0xFFE5704F),
    alertSoft: Color(0xFF3A1E17),
    warn: Color(0xFFE2A54A),
    warnSoft: Color(0xFF352813),
    coin: Color(0xFFA3A4E6),
    coinSoft: Color(0xFF24254A),
    onAccent: Color(0xFF0B0F0E),
    // Lifted above the page so the panel still reads as the hero in dark.
    board: Color(0xFF1F2725),
    boardRaised: Color(0xFF2E3735),
    boardInk: Color(0xFFEEF1EC),
    boardMuted: Color(0xFF8E9792),
    pipEmpty: Color(0xFF2B3331),
    scrim: Color(0x99000000),
    shadow: Color(0x33000000),
  );

  @override
  CraftColors copyWith({
    Color? paper,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? hair,
    Color? go,
    Color? goSoft,
    Color? alert,
    Color? alertSoft,
    Color? warn,
    Color? warnSoft,
    Color? coin,
    Color? coinSoft,
    Color? onAccent,
    Color? board,
    Color? boardRaised,
    Color? boardInk,
    Color? boardMuted,
    Color? pipEmpty,
    Color? scrim,
    Color? shadow,
  }) {
    return CraftColors(
      paper: paper ?? this.paper,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      hair: hair ?? this.hair,
      go: go ?? this.go,
      goSoft: goSoft ?? this.goSoft,
      alert: alert ?? this.alert,
      alertSoft: alertSoft ?? this.alertSoft,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      coin: coin ?? this.coin,
      coinSoft: coinSoft ?? this.coinSoft,
      onAccent: onAccent ?? this.onAccent,
      board: board ?? this.board,
      boardRaised: boardRaised ?? this.boardRaised,
      boardInk: boardInk ?? this.boardInk,
      boardMuted: boardMuted ?? this.boardMuted,
      pipEmpty: pipEmpty ?? this.pipEmpty,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  CraftColors lerp(ThemeExtension<CraftColors>? other, double t) {
    if (other is! CraftColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return CraftColors(
      paper: l(paper, other.paper),
      surface: l(surface, other.surface),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      hair: l(hair, other.hair),
      go: l(go, other.go),
      goSoft: l(goSoft, other.goSoft),
      alert: l(alert, other.alert),
      alertSoft: l(alertSoft, other.alertSoft),
      warn: l(warn, other.warn),
      warnSoft: l(warnSoft, other.warnSoft),
      coin: l(coin, other.coin),
      coinSoft: l(coinSoft, other.coinSoft),
      onAccent: l(onAccent, other.onAccent),
      board: l(board, other.board),
      boardRaised: l(boardRaised, other.boardRaised),
      boardInk: l(boardInk, other.boardInk),
      boardMuted: l(boardMuted, other.boardMuted),
      pipEmpty: l(pipEmpty, other.pipEmpty),
      scrim: l(scrim, other.scrim),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension CraftColorsContext on BuildContext {
  /// Theme colours. Falls back to the light palette when no app theme is
  /// installed (e.g. bare widget tests).
  CraftColors get colors =>
      Theme.of(this).extension<CraftColors>() ?? CraftColors.light;
}
