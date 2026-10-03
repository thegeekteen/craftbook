import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/error/result.dart';

abstract class SettingsRepository {
  /// Falls back to [ThemeMode.system] when nothing valid is stored.
  Future<ThemeMode> getThemeMode();

  Future<Result<void>> setThemeMode(ThemeMode mode);
}
