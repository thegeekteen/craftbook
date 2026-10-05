import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_utils.dart' as app_date;
import 'profit_trend.dart';

enum ReportRange { week, month, year, custom }

/// The stretch of time a report covers: a week, month or year counted back
/// from now by [offset], or a custom range of whole days.
class ReportPeriod extends Equatable {
  final ReportRange range;

  /// 0 is the current week/month/year, −1 the one before. Unused for custom.
  final int offset;
  final DateTime? customStart;
  final DateTime? customEnd;

  const ReportPeriod(this.range, {this.offset = 0})
      : customStart = null,
        customEnd = null;

  ReportPeriod.custom(DateTime start, DateTime end)
      : range = ReportRange.custom,
        offset = 0,
        customStart = app_date.DateUtils.startOfDay(start),
        customEnd = app_date.DateUtils.endOfDay(end);

  /// Custom ranges longer than this chart by month instead of by day, so
  /// the bars stay readable.
  static const maxDailyBars = 62;

  bool get isCustom => range == ReportRange.custom;

  /// Future periods have no orders to show.
  bool get canGoForward => !isCustom && offset < 0;

  ReportPeriod shifted(int delta) =>
      isCustom ? this : ReportPeriod(range, offset: offset + delta);

  ({DateTime start, DateTime end}) resolve(DateTime now) {
    switch (range) {
      case ReportRange.week:
        final start =
            app_date.DateUtils.startOfWeek(now).add(Duration(days: 7 * offset));
        return (start: start, end: app_date.DateUtils.endOfWeek(start));
      case ReportRange.month:
        final start = DateTime(now.year, now.month + offset, 1);
        return (start: start, end: app_date.DateUtils.endOfMonth(start));
      case ReportRange.year:
        final year = now.year + offset;
        return (start: DateTime(year), end: DateTime(year, 12, 31, 23, 59, 59));
      case ReportRange.custom:
        return (start: customStart!, end: customEnd!);
    }
  }

  TrendGranularity granularity(DateTime now) {
    if (range == ReportRange.year) return TrendGranularity.month;
    if (!isCustom) return TrendGranularity.day;
    final p = resolve(now);
    return p.end.difference(p.start).inDays < maxDailyBars
        ? TrendGranularity.day
        : TrendGranularity.month;
  }

  /// "This week", "Last month", "March 2026", "Mar 3 – Apr 12"…
  String label(DateTime now) {
    final p = resolve(now);
    if (isCustom) return _span(p.start, p.end, now);
    if (offset == 0) {
      return switch (range) {
        ReportRange.week => 'This week',
        ReportRange.month => 'This month',
        _ => 'This year',
      };
    }
    if (offset == -1 && range != ReportRange.year) {
      return range == ReportRange.week ? 'Last week' : 'Last month';
    }
    return switch (range) {
      ReportRange.week => p.start.month == p.end.month
          ? '${DateFormat('MMM d').format(p.start)} – ${p.end.day}'
          : _span(p.start, p.end, now),
      ReportRange.month => DateFormat('MMMM y').format(p.start),
      _ => '${p.start.year}',
    };
  }

  /// The dates behind a relative [label], or the length of a custom range;
  /// null when the label already says it all.
  String? detail(DateTime now) {
    final p = resolve(now);
    if (isCustom) {
      final days = p.end.difference(p.start).inDays + 1;
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
    if (offset != 0 && !(offset == -1 && range != ReportRange.year)) {
      return null;
    }
    return switch (range) {
      ReportRange.week =>
        '${DateFormat('MMM d').format(p.start)} – ${DateFormat('MMM d').format(p.end)}',
      ReportRange.month => DateFormat('MMMM y').format(p.start),
      _ => '${p.start.year}',
    };
  }

  static String _span(DateTime start, DateTime end, DateTime now) {
    final sameYear = start.year == end.year;
    final fmt =
        DateFormat(sameYear && start.year == now.year ? 'MMM d' : 'MMM d, y');
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return fmt.format(start);
    }
    final startFmt =
        sameYear && start.year != now.year ? DateFormat('MMM d') : fmt;
    return '${startFmt.format(start)} – ${fmt.format(end)}';
  }

  @override
  List<Object?> get props => [range, offset, customStart, customEnd];
}
