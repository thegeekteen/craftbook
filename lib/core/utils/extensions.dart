import 'package:flutter/material.dart';
import '../theme/colors.dart';

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
  /// Format as currency
  String get currency {
    return '₱${toStringAsFixed(2)}';
  }

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
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.alert : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
