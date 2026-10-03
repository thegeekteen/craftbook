import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency formatter for PHP (Philippine Peso)
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  /// Losses use the true minus sign (−), matching the rest of the UI.
  static String format(double amount) {
    if (amount < 0) return '−${_formatter.format(-amount)}';
    return _formatter.format(amount);
  }

  /// Drops ".00" on whole amounts (₱412 instead of ₱412.00) but keeps
  /// real centavos. Used for headline numbers where the zeros are noise.
  static String formatShort(double amount) {
    if (amount < 0) return '−${formatShort(-amount)}';
    final rounded = amount.roundToDouble();
    if ((amount - rounded).abs() < 0.005) {
      return _wholeFormatter.format(rounded);
    }
    return format(amount);
  }

  static final NumberFormat _wholeFormatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static String formatCompact(double amount) {
    final sign = amount < 0 ? '−' : '';
    final abs = amount.abs();
    if (abs >= 1000000) {
      return '$sign${AppConstants.currencySymbol}${(abs / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      return '$sign${AppConstants.currencySymbol}${(abs / 1000).toStringAsFixed(1)}K';
    }
    return formatShort(amount);
  }

  static String formatWithoutSymbol(double amount) {
    return amount.toStringAsFixed(2);
  }
}
