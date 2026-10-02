import 'package:flutter_test/flutter_test.dart';

import 'package:craftbook/core/utils/currency_formatter.dart';
import 'package:craftbook/core/utils/date_utils.dart' as app_utils;

void main() {
  group('CurrencyFormatter', () {
    test('formats amount with peso symbol', () {
      final result = CurrencyFormatter.format(1234.56);
      expect(result, contains('1,234.56'));
    });

    test('formats compact thousands', () {
      final result = CurrencyFormatter.formatCompact(5000);
      expect(result, contains('5.0K'));
    });

    test('formats compact millions', () {
      final result = CurrencyFormatter.formatCompact(1500000);
      expect(result, contains('1.5M'));
    });

    test('formatWithoutSymbol returns number only', () {
      final result = CurrencyFormatter.formatWithoutSymbol(99.5);
      expect(result, '99.50');
    });
  });

  group('DateUtils', () {
    test('startOfDay returns midnight', () {
      final date = DateTime(2026, 8, 26, 14, 30);
      final start = app_utils.DateUtils.startOfDay(date);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });

    test('endOfDay returns 23:59:59', () {
      final date = DateTime(2026, 8, 26, 14, 30);
      final end = app_utils.DateUtils.endOfDay(date);
      expect(end.hour, 23);
      expect(end.minute, 59);
      expect(end.second, 59);
    });

    test('isSameDay returns true for same date', () {
      final a = DateTime(2026, 8, 26, 10, 30);
      final b = DateTime(2026, 8, 26, 22, 15);
      expect(app_utils.DateUtils.isSameDay(a, b), true);
    });

    test('isSameDay returns false for different dates', () {
      final a = DateTime(2026, 8, 26);
      final b = DateTime(2026, 8, 27);
      expect(app_utils.DateUtils.isSameDay(a, b), false);
    });

    test('startOfWeek returns Monday', () {
      // Aug 26, 2026 is a Wednesday
      final wed = DateTime(2026, 8, 26);
      final monday = app_utils.DateUtils.startOfWeek(wed);
      expect(monday.weekday, DateTime.monday);
      expect(monday.day, 24);
    });

    test('startOfMonth returns first day', () {
      final date = DateTime(2026, 8, 26);
      final start = app_utils.DateUtils.startOfMonth(date);
      expect(start.day, 1);
      expect(start.month, 8);
    });
  });
}
