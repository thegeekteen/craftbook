import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/theme/palettes.dart';

/// How the app looks: [mode] is Auto/On/Off for dark, [palette] the colours.
class ThemeSettings extends Equatable {
  final ThemeMode mode;
  final AppPalette palette;

  const ThemeSettings({
    this.mode = ThemeMode.system,
    this.palette = AppPalette.forest,
  });

  ThemeSettings copyWith({ThemeMode? mode, AppPalette? palette}) =>
      ThemeSettings(mode: mode ?? this.mode, palette: palette ?? this.palette);

  @override
  List<Object?> get props => [mode, palette];
}
