import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const themeModeKey = 'theme_mode';

  final AppDatabase db;

  SettingsRepositoryImpl(this.db);

  @override
  Future<ThemeMode> getThemeMode() async {
    // A theme preference must never stop the app from starting.
    try {
      final row = await (db.select(db.settings)
            ..where((s) => s.key.equals(themeModeKey)))
          .getSingleOrNull();
      return ThemeMode.values.asNameMap()[row?.value] ?? ThemeMode.system;
    } catch (_) {
      return ThemeMode.system;
    }
  }

  @override
  Future<Result<void>> setThemeMode(ThemeMode mode) async {
    try {
      // The conflict is on the unique `key`, not the autoincrement id.
      await db.into(db.settings).insert(
            SettingsCompanion.insert(key: themeModeKey, value: mode.name),
            onConflict: DoUpdate(
              (_) => SettingsCompanion(value: Value(mode.name)),
              target: [db.settings.key],
            ),
          );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }
}
