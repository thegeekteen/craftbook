import 'package:craftbook/features/earnings/domain/entities/profit_trend.dart';
import 'package:craftbook/features/earnings/domain/entities/report_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A Monday.
  final now = DateTime(2026, 10, 5, 15);

  group('week, month, year', () {
    test('this week runs Monday to Sunday', () {
      final p = const ReportPeriod(ReportRange.week).resolve(now);
      expect(p.start, DateTime(2026, 10, 5));
      expect(p.end.day, 11);
    });

    test('last month, labelled', () {
      const period = ReportPeriod(ReportRange.month, offset: -1);
      final p = period.resolve(now);
      expect(p.start, DateTime(2026, 9, 1));
      expect(p.end.month, 9);
      expect(period.label(now), 'Last month');
      expect(period.detail(now), 'September 2026');
    });

    test('older periods are named by their dates', () {
      expect(const ReportPeriod(ReportRange.month, offset: -3).label(now),
          'July 2026');
      expect(
          const ReportPeriod(ReportRange.year, offset: -1).label(now), '2025');
      expect(
          const ReportPeriod(ReportRange.year, offset: -1).detail(now), isNull);
    });

    test('shifting moves back and forward, but not past now', () {
      const p = ReportPeriod(ReportRange.week);
      expect(p.canGoForward, isFalse);
      expect(p.shifted(-1).canGoForward, isTrue);
      expect(p.shifted(-1).label(now), 'Last week');
    });

    test('a year charts by month, others by day', () {
      expect(const ReportPeriod(ReportRange.year).granularity(now),
          TrendGranularity.month);
      expect(const ReportPeriod(ReportRange.month).granularity(now),
          TrendGranularity.day);
    });
  });

  group('custom', () {
    test('covers whole days from start to end', () {
      final period = ReportPeriod.custom(
          DateTime(2026, 3, 3, 14), DateTime(2026, 4, 12, 9));
      final p = period.resolve(now);
      expect(p.start, DateTime(2026, 3, 3));
      expect(p.end, DateTime(2026, 4, 12, 23, 59, 59));
      expect(period.label(now), 'Mar 3 – Apr 12');
      expect(period.detail(now), '41 days');
    });

    test('a single day reads as one date', () {
      final period =
          ReportPeriod.custom(DateTime(2026, 3, 3), DateTime(2026, 3, 3));
      expect(period.label(now), 'Mar 3');
      expect(period.detail(now), '1 day');
    });

    test('another year shows the year', () {
      final period =
          ReportPeriod.custom(DateTime(2025, 1, 1), DateTime(2025, 2, 1));
      expect(period.label(now), 'Jan 1 – Feb 1, 2025');
    });

    test('cannot be shifted', () {
      final period =
          ReportPeriod.custom(DateTime(2026, 3, 3), DateTime(2026, 3, 9));
      expect(period.canGoForward, isFalse);
      expect(period.shifted(-1), period);
    });

    test('long ranges chart by month', () {
      expect(
          ReportPeriod.custom(DateTime(2026, 1, 1), DateTime(2026, 2, 1))
              .granularity(now),
          TrendGranularity.day);
      expect(
          ReportPeriod.custom(DateTime(2026, 1, 1), DateTime(2026, 6, 1))
              .granularity(now),
          TrendGranularity.month);
    });
  });
}
