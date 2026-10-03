import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';

/// App-wide theme choice: Auto (system), On (dark) or Off (light).
class ThemeCubit extends Cubit<ThemeMode> {
  final SettingsRepository repository;

  ThemeCubit(this.repository) : super(ThemeMode.system);

  Future<void> load() async => emit(await repository.getThemeMode());

  /// Applies immediately; persisting is best-effort so a failed write only
  /// means the choice isn't remembered next launch.
  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await repository.setThemeMode(mode);
  }
}
