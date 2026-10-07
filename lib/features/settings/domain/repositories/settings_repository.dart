import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/error/result.dart';
import '../../../../core/theme/palettes.dart';
import '../../../../core/utils/currency_setting.dart';
import '../entities/app_language.dart';
import '../entities/order_amount_shown.dart';
import '../entities/tax_settings.dart';

abstract class SettingsRepository {
  /// Falls back to [ThemeMode.system] when nothing valid is stored.
  Future<ThemeMode> getThemeMode();

  Future<Result<void>> setThemeMode(ThemeMode mode);

  /// Falls back to [AppPalette.forest] when nothing valid is stored.
  Future<AppPalette> getPalette();

  Future<Result<void>> setPalette(AppPalette palette);

  /// Falls back to [OrderAmountShown.total] when nothing valid is stored.
  Future<OrderAmountShown> getOrderAmountShown();

  Future<Result<void>> setOrderAmountShown(OrderAmountShown shown);

  /// Falls back to [CurrencySetting.php] when nothing valid is stored.
  Future<CurrencySetting> getCurrency();

  Future<Result<void>> setCurrency(CurrencySetting currency);

  /// Falls back to [AppLanguage.system] when nothing valid is stored.
  Future<AppLanguage> getLanguage();

  Future<Result<void>> setLanguage(AppLanguage language);

  /// Falls back to tax off at 12% included when nothing valid is stored.
  Future<TaxSettings> getTaxSettings();

  Future<Result<void>> setTaxSettings(TaxSettings tax);
}
