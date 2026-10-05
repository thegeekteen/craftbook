import 'package:intl/intl.dart';

import 'currency_setting.dart';

/// Formats amounts in the shop's currency. Static so the many call sites
/// stay simple; [configure] switches the currency for the whole app.
class CurrencyFormatter {
  static CurrencySetting _currency = CurrencySetting.php;
  static NumberFormat _formatter = _build(_currency.decimals);
  static NumberFormat _wholeFormatter = _build(0);

  static NumberFormat _build(int decimals) => NumberFormat.currency(
        locale: 'en_US',
        symbol: _currency.symbol,
        decimalDigits: decimals,
      );

  static CurrencySetting get currency => _currency;

  static String get symbol => _currency.symbol;

  /// Decimal places amounts are written with (0 for yen, 2 for most).
  static int get decimals => _currency.decimals;

  static void configure(CurrencySetting currency) {
    _currency = currency;
    _formatter = _build(currency.decimals);
    _wholeFormatter = _build(0);
  }

  /// Losses use the true minus sign (−), matching the rest of the UI.
  static String format(double amount) {
    if (amount < 0) return '−${_formatter.format(-amount)}';
    return _formatter.format(amount);
  }

  /// Drops ".00" on whole amounts (₱412 instead of ₱412.00) but keeps
  /// real cents. Used for headline numbers where the zeros are noise.
  static String formatShort(double amount) {
    if (amount < 0) return '−${formatShort(-amount)}';
    final rounded = amount.roundToDouble();
    if ((amount - rounded).abs() < 0.005) {
      return _wholeFormatter.format(rounded);
    }
    return format(amount);
  }

  static String formatCompact(double amount) {
    final sign = amount < 0 ? '−' : '';
    final abs = amount.abs();
    if (abs >= 1000000) {
      return '$sign$symbol${(abs / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      return '$sign$symbol${(abs / 1000).toStringAsFixed(1)}K';
    }
    return formatShort(amount);
  }

  static String formatWithoutSymbol(double amount) {
    return amount.toStringAsFixed(_currency.decimals);
  }
}
