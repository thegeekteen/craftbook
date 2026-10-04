import 'package:intl/intl.dart';

import 'entities/order_field.dart';

/// How field values are stored. Every value is TEXT; an empty value is never
/// stored (no row means empty).
///
/// - text: trimmed
/// - number: canonical decimal (`12.50` → `12.5`)
/// - date: `yyyy-MM-dd`
/// - choice: the option label as written
abstract final class OrderFieldCodec {
  static final _isoDate = DateFormat('yyyy-MM-dd');
  static final _displayDate = DateFormat('EEE, MMM d, y');

  /// Trims every value and drops the empty ones.
  static Map<int, String> normalize(Map<int, String> values) => {
        for (final e in values.entries)
          if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
      };

  /// Null when [input] isn't a number.
  static String? encodeNumber(String input) {
    final n = num.tryParse(input.trim());
    if (n == null || !n.isFinite) return null;
    if (n is double && n == n.truncateToDouble()) return n.toInt().toString();
    return n.toString();
  }

  static String encodeDate(DateTime date) => _isoDate.format(date);

  static DateTime? decodeDate(String value) {
    try {
      return _isoDate.parseStrict(value);
    } on FormatException {
      return null;
    }
  }

  /// The value as the user should read it.
  static String display(OrderField field, String value) {
    if (field.type == OrderFieldType.date) {
      final date = decodeDate(value);
      if (date != null) return _displayDate.format(date);
    }
    return value;
  }
}
