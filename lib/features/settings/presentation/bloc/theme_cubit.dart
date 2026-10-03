import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/palettes.dart';
import '../../domain/entities/theme_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// App-wide look: dark mode Auto/On/Off plus the colour scheme.
class ThemeCubit extends Cubit<ThemeSettings> {
  final SettingsRepository repository;

  ThemeCubit(this.repository) : super(const ThemeSettings());

  Future<void> load() async => emit(ThemeSettings(
        mode: await repository.getThemeMode(),
        palette: await repository.getPalette(),
      ));

  /// Applies immediately; persisting is best-effort so a failed write only
  /// means the choice isn't remembered next launch.
  Future<void> setMode(ThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await repository.setThemeMode(mode);
  }

  Future<void> setPalette(AppPalette palette) async {
    emit(state.copyWith(palette: palette));
    await repository.setPalette(palette);
  }
}
