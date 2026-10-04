import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'currency_formatter.dart';

/// Extension methods for common operations
extension StringExtension on String {
  /// Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

extension DateTimeExtension on DateTime {
  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get date only (without time)
  DateTime get dateOnly => DateTime(year, month, day);
}

extension DoubleExtension on double {
  /// Format as currency with thousands separators (₱1,234.50).
  String get currency => CurrencyFormatter.format(this);

  /// Currency without trailing ".00" on whole amounts (₱1,234).
  String get currencyShort => CurrencyFormatter.formatShort(this);

  /// Format as percentage
  String percentage({int decimals = 1}) {
    return '${toStringAsFixed(decimals)}%';
  }
}

extension IntExtension on int {
  /// Format with thousand separator
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

extension BuildContextExtension on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Show snackbar
  /// With [onAction], the snackbar carries a button such as Undo.
  void showSnackBar(
    String message, {
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final c = colors;
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_rounded,
                size: 18,
                color: isError ? c.alert : c.goSoft,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          action: onAction == null
              ? null
              : SnackBarAction(
                  label: actionLabel ?? 'Undo', onPressed: onAction),
        ),
      );
  }
}
