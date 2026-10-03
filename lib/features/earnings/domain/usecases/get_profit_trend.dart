import '../../../../core/error/result.dart';
import '../entities/profit_trend.dart';
import '../repositories/earnings_repository.dart';

/// Profit per day (or per month) across a period, with empty buckets kept
/// so the chart shows quiet days as zero.
class GetProfitTrend {
  final EarningsRepository repository;

  GetProfitTrend(this.repository);

  Future<Result<List<TrendBucket>>> call({
    required DateTime start,
    required DateTime end,
    required TrendGranularity granularity,
  }) async {
    final result = await repository.getCompletedOrderProfits(start, end);
    switch (result) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        return Success(bucket(value, start: start, end: end, granularity: granularity));
    }
  }

  /// Groups [points] into consecutive buckets from [start] to [end].
  static List<TrendBucket> bucket(
    List<ProfitPoint> points, {
    required DateTime start,
    required DateTime end,
    required TrendGranularity granularity,
  }) {
    DateTime keyOf(DateTime d) => granularity == TrendGranularity.day
        ? DateTime(d.year, d.month, d.day)
        : DateTime(d.year, d.month);
    DateTime next(DateTime d) => granularity == TrendGranularity.day
        ? DateTime(d.year, d.month, d.day + 1)
        : DateTime(d.year, d.month + 1);

    final totals = <DateTime, double>{};
    for (final p in points) {
      final k = keyOf(p.completedAt);
      totals[k] = (totals[k] ?? 0) + p.profit;
    }

    final buckets = <TrendBucket>[];
    for (var k = keyOf(start); !k.isAfter(end); k = next(k)) {
      buckets.add(TrendBucket(start: k, profit: totals[k] ?? 0));
    }
    return buckets;
  }
}
