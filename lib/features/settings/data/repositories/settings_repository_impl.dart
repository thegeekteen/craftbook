import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/palettes.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/order_amount_shown.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const themeModeKey = 'theme_mode';
  static const paletteKey = 'palette';
  static const orderAmountKey = 'order_amount';

  final AppDatabase db;

  SettingsRepositoryImpl(this.db);

  @override
  Future<ThemeMode> getThemeMode() async =>
      ThemeMode.values.asNameMap()[await _read(themeModeKey)] ??
      ThemeMode.system;

  @override
  Future<Result<void>> setThemeMode(ThemeMode mode) =>
      _write(themeModeKey, mode.name);

  @override
  Future<AppPalette> getPalette() async =>
      AppPalette.fromName(await _read(paletteKey));

  @override
  Future<Result<void>> setPalette(AppPalette palette) =>
      _write(paletteKey, palette.name);

  @override
  Future<OrderAmountShown> getOrderAmountShown() async =>
      OrderAmountShown.values.asNameMap()[await _read(orderAmountKey)] ??
      OrderAmountShown.total;

  @override
  Future<Result<void>> setOrderAmountShown(OrderAmountShown shown) =>
      _write(orderAmountKey, shown.name);

  /// Display preferences must never stop the app from starting, so a failed read is
  /// the same as nothing stored.
  Future<String?> _read(String key) async {
    try {
      final row = await (db.select(db.settings)
            ..where((s) => s.key.equals(key)))
          .getSingleOrNull();
      return row?.value;
    } catch (_) {
      return null;
    }
  }

  Future<Result<void>> _write(String key, String value) async {
    try {
      // The conflict is on the unique `key`, not the autoincrement id.
      await db.into(db.settings).insert(
            SettingsCompanion.insert(key: key, value: value),
            onConflict: DoUpdate(
              (_) => SettingsCompanion(value: Value(value)),
              target: [db.settings.key],
            ),
          );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }
}
