import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/earnings/domain/entities/profit_trend.dart';
import 'package:craftbook/features/earnings/domain/repositories/earnings_repository.dart';
import 'package:craftbook/features/earnings/domain/usecases/get_profit_trend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEarningsRepository extends Mock implements EarningsRepository {}

void main() {
  group('GetProfitTrend.bucket', () {
    test('daily buckets cover every day, summing same-day orders', () {
      final buckets = GetProfitTrend.bucket(
        [
          ProfitPoint(completedAt: DateTime(2026, 9, 28, 9), profit: 100),
          ProfitPoint(completedAt: DateTime(2026, 9, 28, 18), profit: 50),
          ProfitPoint(completedAt: DateTime(2026, 9, 30, 12), profit: -20),
        ],
        start: DateTime(2026, 9, 28),
        end: DateTime(2026, 10, 4, 23, 59, 59),
        granularity: TrendGranularity.day,
      );

      expect(buckets, hasLength(7));
      expect(buckets.first,
          TrendBucket(start: DateTime(2026, 9, 28), profit: 150));
      expect(buckets[1].profit, 0);
      expect(buckets[2].profit, -20);
      expect(buckets.last.start, DateTime(2026, 10, 4));
    });

    test('monthly buckets cover the year', () {
      final buckets = GetProfitTrend.bucket(
        [ProfitPoint(completedAt: DateTime(2026, 3, 15), profit: 300)],
        start: DateTime(2026),
        end: DateTime(2026, 12, 31, 23, 59, 59),
        granularity: TrendGranularity.month,
      );

      expect(buckets, hasLength(12));
      expect(buckets[2], TrendBucket(start: DateTime(2026, 3), profit: 300));
      expect(buckets.where((b) => b.profit != 0), hasLength(1));
    });

    test('no orders still yields zero buckets', () {
      final buckets = GetProfitTrend.bucket(
        const [],
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 2, 28, 23, 59, 59),
        granularity: TrendGranularity.day,
      );
      expect(buckets, hasLength(28));
      expect(buckets.every((b) => b.profit == 0), isTrue);
    });
  });

  group('GetProfitTrend', () {
    late MockEarningsRepository repo;
    late GetProfitTrend useCase;
    final start = DateTime(2026, 10, 1);
    final end = DateTime(2026, 10, 3, 23, 59, 59);

    setUp(() {
      repo = MockEarningsRepository();
      useCase = GetProfitTrend(repo);
    });

    test('buckets repository points', () async {
      when(() => repo.getCompletedOrderProfits(start, end))
          .thenAnswer((_) async => Success([
                ProfitPoint(completedAt: DateTime(2026, 10, 2, 8), profit: 40),
              ]));

      final result = await useCase(
          start: start, end: end, granularity: TrendGranularity.day);

      switch (result) {
        case Success(:final value):
          expect(value.map((b) => b.profit), [0, 40, 0]);
        case Error():
          fail('expected success');
      }
    });

    test('passes repository failures through', () async {
      when(() => repo.getCompletedOrderProfits(start, end))
          .thenAnswer((_) async => const Error(DatabaseFailure('boom')));

      final result = await useCase(
          start: start, end: end, granularity: TrendGranularity.day);

      expect(result, isA<Error<List<TrendBucket>>>());
    });
  });
}
