import 'package:flutter/material.dart';

import 'colors.dart';

/// The selectable colour schemes. Each has a light and a dark [CraftColors].
///
/// Meaning stays fixed across schemes: `alert` is always red-family and
/// `warn` amber-family, so cost and fees read the same whatever the accent.
/// Only the accent, money colour and tinted neutrals change.
enum AppPalette {
  forest('Forest', CraftColors.light, CraftColors.dark),
  berry('Berry', _berryLight, _berryDark),
  ocean('Ocean', _oceanLight, _oceanDark),
  sunset('Sunset', _sunsetLight, _sunsetDark);

  const AppPalette(this.label, this.light, this.dark);

  final String label;
  final CraftColors light;
  final CraftColors dark;

  CraftColors forBrightness(Brightness b) =>
      b == Brightness.dark ? dark : light;

  /// Looks a stored name up; anything unknown is the default scheme.
  static AppPalette fromName(String? name) =>
      AppPalette.values.asNameMap()[name] ?? AppPalette.forest;
}

const _berryLight = CraftColors(
  paper: Color(0xFFF8F1F3),
  surface: Color(0xFFFFFFFF),
  ink: Color(0xFF1E1419),
  muted: Color(0xFF74656C),
  hair: Color(0xFFE8DAE0),
  go: Color(0xFFA02A63),
  goSoft: Color(0xFFF7DFEA),
  alert: Color(0xFFB93B22),
  alertSoft: Color(0xFFF6E1DA),
  warn: Color(0xFFA86D12),
  warnSoft: Color(0xFFF7ECD6),
  coin: Color(0xFF3C5F8F),
  coinSoft: Color(0xFFE1E8F3),
  onAccent: Color(0xFFFFFFFF),
  board: Color(0xFF2B1824),
  boardRaised: Color(0xFF3B2533),
  boardInk: Color(0xFFF6EEF1),
  boardMuted: Color(0xFFB09AA5),
  pipEmpty: Color(0xFFE6D8DE),
  scrim: Color(0x730F0A0D),
  shadow: Color(0x14000000),
);

const _berryDark = CraftColors(
  paper: Color(0xFF151014),
  surface: Color(0xFF1E171C),
  ink: Color(0xFFEFE6EA),
  muted: Color(0xFF9C8E95),
  hair: Color(0xFF32262D),
  go: Color(0xFFE877AA),
  goSoft: Color(0xFF3A1A2B),
  alert: Color(0xFFE5704F),
  alertSoft: Color(0xFF3A1E17),
  warn: Color(0xFFE2A54A),
  warnSoft: Color(0xFF352813),
  coin: Color(0xFF8FB2E6),
  coinSoft: Color(0xFF1F2B45),
  onAccent: Color(0xFF160C11),
  board: Color(0xFF2A1D25),
  boardRaised: Color(0xFF3A2A34),
  boardInk: Color(0xFFF3ECEF),
  boardMuted: Color(0xFF9D8F96),
  pipEmpty: Color(0xFF33282F),
  scrim: Color(0x99000000),
  shadow: Color(0x33000000),
);

const _oceanLight = CraftColors(
  paper: Color(0xFFF1F5F7),
  surface: Color(0xFFFFFFFF),
  ink: Color(0xFF0F1A1F),
  muted: Color(0xFF5F6E75),
  hair: Color(0xFFD9E2E6),
  go: Color(0xFF0B6E8A),
  goSoft: Color(0xFFD9ECF2),
  alert: Color(0xFFB93B22),
  alertSoft: Color(0xFFF6E1DA),
  warn: Color(0xFFA86D12),
  warnSoft: Color(0xFFF7ECD6),
  coin: Color(0xFF5A4A9E),
  coinSoft: Color(0xFFE6E2F4),
  onAccent: Color(0xFFFFFFFF),
  board: Color(0xFF12252E),
  boardRaised: Color(0xFF1E3541),
  boardInk: Color(0xFFEEF4F6),
  boardMuted: Color(0xFF94A9B2),
  pipEmpty: Color(0xFFD6E0E4),
  scrim: Color(0x730A0F12),
  shadow: Color(0x14000000),
);

const _oceanDark = CraftColors(
  paper: Color(0xFF0E1417),
  surface: Color(0xFF151D21),
  ink: Color(0xFFE4EDF0),
  muted: Color(0xFF8A9BA2),
  hair: Color(0xFF25323A),
  go: Color(0xFF4DB8D6),
  goSoft: Color(0xFF12303A),
  alert: Color(0xFFE5704F),
  alertSoft: Color(0xFF3A1E17),
  warn: Color(0xFFE2A54A),
  warnSoft: Color(0xFF352813),
  coin: Color(0xFFB3A6EE),
  coinSoft: Color(0xFF262248),
  onAccent: Color(0xFF08141A),
  board: Color(0xFF1B2A32),
  boardRaised: Color(0xFF273A44),
  boardInk: Color(0xFFECF3F5),
  boardMuted: Color(0xFF8A9CA4),
  pipEmpty: Color(0xFF26333A),
  scrim: Color(0x99000000),
  shadow: Color(0x33000000),
);

// Orange sits between red and amber, so alert leans crimson and warn gold
// here to keep all three apart.
const _sunsetLight = CraftColors(
  paper: Color(0xFFFAF3EA),
  surface: Color(0xFFFFFCF8),
  ink: Color(0xFF211713),
  muted: Color(0xFF7A6A5F),
  hair: Color(0xFFEADFD1),
  go: Color(0xFFC0481A),
  goSoft: Color(0xFFF8E3D3),
  alert: Color(0xFFB0213A),
  alertSoft: Color(0xFFF6DDE0),
  warn: Color(0xFF9A7400),
  warnSoft: Color(0xFFF6EDCB),
  coin: Color(0xFF4B4C8A),
  coinSoft: Color(0xFFE4E4F2),
  onAccent: Color(0xFFFFFFFF),
  board: Color(0xFF2C1D16),
  boardRaised: Color(0xFF3D2A21),
  boardInk: Color(0xFFF8EFE6),
  boardMuted: Color(0xFFB3A092),
  pipEmpty: Color(0xFFE8DDCE),
  scrim: Color(0x730F0A07),
  shadow: Color(0x14000000),
);

const _sunsetDark = CraftColors(
  paper: Color(0xFF16110E),
  surface: Color(0xFF201915),
  ink: Color(0xFFF0E8E0),
  muted: Color(0xFFA0948A),
  hair: Color(0xFF362C25),
  go: Color(0xFFF0834A),
  goSoft: Color(0xFF3A2214),
  alert: Color(0xFFEF6A7C),
  alertSoft: Color(0xFF3D1A20),
  warn: Color(0xFFF2D03C),
  warnSoft: Color(0xFF352E10),
  coin: Color(0xFFA3A4E6),
  coinSoft: Color(0xFF24254A),
  onAccent: Color(0xFF140C07),
  board: Color(0xFF2B211C),
  boardRaised: Color(0xFF3B2F28),
  boardInk: Color(0xFFF4ECE4),
  boardMuted: Color(0xFFA19488),
  pipEmpty: Color(0xFF372D26),
  scrim: Color(0x99000000),
  shadow: Color(0x33000000),
);
