import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [range, offset, customStart, customEnd];
}
