import 'package:intl/intl.dart';

/// Formats quantities: how much of a material or product there is.
///
/// Kept apart from `CurrencyFormatter` because a quantity carries no symbol
/// and no fixed decimal places. Whole amounts read as "3", not "3.00", and a
/// fraction keeps only the digits it needs ("1.25", "0.111"). There are no
/// thousand separators either, so a whole number reads exactly as it did
/// before quantities could be fractional.
class QuantityFormatter {
  QuantityFormatter._();

  static final NumberFormat _numbers = NumberFormat('0.###', 'en_US');

  static String format(num value) => _numbers.format(value);

  /// "1.25 board", "3 pc". A missing unit gives just the number.
  static String withUnit(num value, String? unit) {
    final text = format(value);
    return unit == null || unit.isEmpty ? text : '$text $unit';
  }
}
