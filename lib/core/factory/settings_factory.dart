import 'dart:math';

import 'package:flutter/material.dart' show ThemeMode;

import '../../features/settings/domain/entities/order_amount_shown.dart';
import '../../features/settings/domain/entities/tax_settings.dart';
import '../theme/palettes.dart';
import '../utils/currency_setting.dart';
import 'fake_random.dart';
import 'fake_shop.dart';

/// The shop's own settings, so every money screen has known numbers behind it.
///
/// Tax is always switched on: a shop with tax off never exercises the two ways
/// it can be charged, and the order screens that read them. The currency is
/// always one written with cents for the same reason — a rounding error is
/// invisible in a whole-number currency.
SettingsPlan buildSettings(Random random) {
  // Two decimals only, so ₱1,234.56 shows the cents a report has to add up.
  final centCurrencies =
      CurrencySetting.presets.where((c) => c.decimals == 2).toList();
  final currency = random.oneOf(centCurrencies);

  return SettingsPlan(
    currencyCode: currency.code,
    currencySymbol: currency.symbol,
    currencyDecimals: currency.decimals,
    taxEnabled: true,
    taxOnByDefault: !random.oneIn(3),
    taxRate: random.oneOf(const [8, 10, 12]).toDouble(),
    taxInclusive: random.oneOf(const [true, false]),
    taxLabel: random.oneOfOrNull(const [
          TaxSettings.defaultLabel,
          'GST',
          'Sales tax',
        ], blankOutOf: 8) ??
        TaxSettings.defaultLabel,
    themeMode: random.oneOf(ThemeMode.values).name,
    palette: random.oneOf(AppPalette.values).name,
    orderAmountShown: random.oneOf(OrderAmountShown.values).name,
  );
}
