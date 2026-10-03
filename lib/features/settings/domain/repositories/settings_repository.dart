import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/error/result.dart';
import '../../../../core/theme/palettes.dart';

abstract class SettingsRepository {
  /// Falls back to [ThemeMode.system] when nothing valid is stored.
  Future<ThemeMode> getThemeMode();

  Future<Result<void>> setThemeMode(ThemeMode mode);

  /// Falls back to [AppPalette.forest] when nothing valid is stored.
  Future<AppPalette> getPalette();

  Future<Result<void>> setPalette(AppPalette palette);
}
