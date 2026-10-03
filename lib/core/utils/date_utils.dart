import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Date utility helpers
class DateUtils {
  DateUtils._();

  /// Format date as "dd MMM yyyy" (e.g., "26 Aug 2026")
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format time as "HH:mm" (e.g., "14:30")
  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  /// Format date and time as "dd MMM yyyy HH:mm"
  static String formatDateTime(DateTime date) {
    return DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    final diff = weekday == DateTime.monday ? 0 : weekday - DateTime.monday;
    return startOfDay(date.subtract(Duration(days: diff)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final start = startOfWeek(date);
    return endOfDay(start.add(const Duration(days: 6)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return endOfDay(nextMonth.subtract(const Duration(days: 1)));
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Get relative date string (e.g., "Today", "Tomorrow", "Yesterday")
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = startOfDay(now);
    final target = startOfDay(date);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1 && diff <= 7) return 'In $diff days';
    if (diff < -1 && diff >= -7) return '$diff days ago';
    return formatDate(date);
  }

  /// Short human date: "Today", "Tomorrow", "Yesterday", "Wed, Oct 7",
  /// or "Oct 7, 2025" outside the current year.
  static String friendly(DateTime date, {DateTime? now}) {
    final today = startOfDay(now ?? DateTime.now());
    final diff = startOfDay(date).difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (date.year != today.year) return DateFormat('MMM d, y').format(date);
    return DateFormat('EEE, MMM d').format(date);
  }

  /// Days from today to [date] (negative when in the past).
  static int daysFromToday(DateTime date, {DateTime? now}) =>
      startOfDay(date).difference(startOfDay(now ?? DateTime.now())).inDays;
}
