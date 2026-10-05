import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/palettes.dart';
import '../../../../core/utils/currency_setting.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/order_amount_shown.dart';
import '../../domain/entities/tax_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const themeModeKey = 'theme_mode';
  static const paletteKey = 'palette';
  static const orderAmountKey = 'order_amount';
  static const currencyCodeKey = 'currency_code';
  static const currencySymbolKey = 'currency_symbol';
  static const currencyDecimalsKey = 'currency_decimals';
  static const taxEnabledKey = 'tax_enabled';
  static const taxOnByDefaultKey = 'tax_on_by_default';
  static const taxRateKey = 'tax_rate';
  static const taxInclusiveKey = 'tax_inclusive';
  static const taxLabelKey = 'tax_label';

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

  @override
  Future<CurrencySetting> getCurrency() async {
    final code = await _read(currencyCodeKey);
    if (code == null) return CurrencySetting.php;
    final preset = CurrencySetting.preset(code);
    if (preset != null) return preset;
    final symbol = (await _read(currencySymbolKey))?.trim() ?? '';
    if (code != CurrencySetting.customCode || symbol.isEmpty) {
      return CurrencySetting.php;
    }
    final decimals = int.tryParse(await _read(currencyDecimalsKey) ?? '');
    return CurrencySetting(
      code: CurrencySetting.customCode,
      symbol: symbol,
      decimals: decimals == 0 ? 0 : 2,
    );
  }

  @override
  Future<Result<void>> setCurrency(CurrencySetting currency) async {
    for (final (key, value) in [
      (currencyCodeKey, currency.code),
      (currencySymbolKey, currency.symbol),
      (currencyDecimalsKey, '${currency.decimals}'),
    ]) {
      final result = await _write(key, value);
      if (result is Error<void>) return result;
    }
    return const Success(null);
  }

  @override
  Future<TaxSettings> getTaxSettings() async {
    const fallback = TaxSettings();
    final rate = double.tryParse(await _read(taxRateKey) ?? '');
    final label = (await _read(taxLabelKey))?.trim() ?? '';
    return TaxSettings(
      enabled: await _read(taxEnabledKey) == 'true',
      onByDefault: await _read(taxOnByDefaultKey) != 'false',
      rate: rate != null && rate >= 0 && rate <= 100 ? rate : fallback.rate,
      inclusive: await _read(taxInclusiveKey) != 'false',
      label: label.isEmpty ? fallback.label : label,
    );
  }

  @override
  Future<Result<void>> setTaxSettings(TaxSettings tax) async {
    for (final (key, value) in [
      (taxEnabledKey, '${tax.enabled}'),
      (taxOnByDefaultKey, '${tax.onByDefault}'),
      (taxRateKey, '${tax.rate}'),
      (taxInclusiveKey, '${tax.inclusive}'),
      (taxLabelKey, tax.label),
    ]) {
      final result = await _write(key, value);
      if (result is Error<void>) return result;
    }
    return const Success(null);
  }

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
