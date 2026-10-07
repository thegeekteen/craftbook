import 'package:intl/intl.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../domain/entities/report_period.dart';

/// How a [ReportPeriod] reads on screen. Lives here, not on the entity, so
/// the domain stays free of translated text.
extension ReportPeriodLabels on ReportPeriod {
  /// "This week", "Last month", "March 2026", "Mar 3 – Apr 12"…
  String label(DateTime now, AppLocalizations l10n) {
    final p = resolve(now);
    if (isCustom) return _span(p.start, p.end, now);
    if (offset == 0) {
      return switch (range) {
        ReportRange.week => l10n.earningsThisWeek,
        ReportRange.month => l10n.earningsThisMonth,
        _ => l10n.earningsThisYear,
      };
    }
    if (offset == -1 && range != ReportRange.year) {
      return range == ReportRange.week
          ? l10n.earningsLastWeek
          : l10n.earningsLastMonth;
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
  String? detail(DateTime now, AppLocalizations l10n) {
    final p = resolve(now);
    if (isCustom) {
      final days = p.end.difference(p.start).inDays + 1;
      return l10n.earningsDays(days);
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

  String _span(DateTime start, DateTime end, DateTime now) {
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
}
