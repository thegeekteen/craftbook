import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency formatter for PHP (Philippine Peso)
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${AppConstants.currencySymbol}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${AppConstants.currencySymbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    return amount.toStringAsFixed(2);
  }
}
