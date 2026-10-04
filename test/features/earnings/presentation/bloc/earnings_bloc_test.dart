import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/earnings/domain/entities/earnings_summary.dart';
import 'package:craftbook/features/earnings/domain/entities/product_earnings.dart';
import 'package:craftbook/features/earnings/domain/entities/profit_trend.dart';
import 'package:craftbook/features/earnings/domain/usecases/get_earnings_summary.dart';
import 'package:craftbook/features/earnings/domain/usecases/get_product_earnings.dart';
import 'package:craftbook/features/earnings/domain/usecases/get_profit_trend.dart';
import 'package:craftbook/features/earnings/domain/usecases/get_waste_summary.dart';
import 'package:craftbook/features/earnings/presentation/bloc/earnings_bloc.dart';
import 'package:craftbook/features/earnings/presentation/bloc/earnings_event.dart';
import 'package:craftbook/features/earnings/presentation/bloc/earnings_state.dart';

class MockGetEarningsSummary extends Mock implements GetEarningsSummary {}

class MockGetProductEarnings extends Mock implements GetProductEarnings {}

class MockGetWasteSummary extends Mock implements GetWasteSummary {}

class MockGetProfitTrend extends Mock implements GetProfitTrend {}

void main() {
  late MockGetEarningsSummary getEarningsSummary;
  late MockGetProductEarnings getProductEarnings;
  late MockGetWasteSummary getWasteSummary;
  late MockGetProfitTrend getProfitTrend;

  final start = DateTime(2026, 9, 1);
  final end = DateTime(2026, 9, 30, 23, 59, 59);
  final otherStart = DateTime(2026, 10, 1);
  final otherEnd = DateTime(2026, 10, 31, 23, 59, 59);

  const summary = EarningsSummary(
    totalSales: 1000,
    totalMaterialCost: 200,
    totalChannelFees: 100,
    totalShippingCost: 50,
    totalProfit: 650,
    orderCount: 4,
  );
  const otherSummary = EarningsSummary(
    totalSales: 500,
    totalMaterialCost: 100,
    totalChannelFees: 50,
    totalShippingCost: 0,
    totalProfit: 350,
    orderCount: 2,
  );
  const waste = WasteSummary(totalWasteQuantity: 2, totalWasteCost: 10);
  final trend = [TrendBucket(start: DateTime(2026, 9, 1), profit: 650)];

  const low = ProductEarnings(
      productId: 1,
      productName: 'Keychain',
      quantitySold: 3,
      totalSales: 360,
      totalProfit: 100);
  const high = ProductEarnings(
      productId: 2,
      productName: 'Tulip',
      quantitySold: 2,
      totalSales: 900,
      totalProfit: 500);
  const mid = ProductEarnings(
      productId: 3,
      productName: 'Strap',
      quantitySold: 1,
      totalSales: 180,
      totalProfit: 120);

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(TrendGranularity.day);
  });

  setUp(() {
    getEarningsSummary = MockGetEarningsSummary();
    getProductEarnings = MockGetProductEarnings();
    getWasteSummary = MockGetWasteSummary();
    getProfitTrend = MockGetProfitTrend();
  });

  EarningsBloc build() => EarningsBloc(
        getEarningsSummary: getEarningsSummary,
        getProductEarnings: getProductEarnings,
        getWasteSummary: getWasteSummary,
        getProfitTrend: getProfitTrend,
      );

  /// Stubs every use case to succeed. The product list is growable because
  /// the bloc sorts it in place.
  void stubAll({EarningsSummary s = summary}) {
    when(() => getEarningsSummary(any(), any()))
        .thenAnswer((_) async => Success(s));
    when(() => getProductEarnings(any(), any()))
        .thenAnswer((_) async => Success(List.of(const [low, high, mid])));
    when(() => getWasteSummary(any(), any()))
        .thenAnswer((_) async => const Success(waste));
    when(() => getProfitTrend(
          start: any(named: 'start'),
          end: any(named: 'end'),
          granularity: any(named: 'granularity'),
        )).thenAnswer((_) async => Success(trend));
  }

  EarningsLoaded loadedFor(DateTime s, DateTime e, EarningsSummary sum) =>
      EarningsLoaded(
        startDate: s,
        endDate: e,
        summary: sum,
        productEarnings: const [high, mid, low],
        wasteSummary: waste,
        trend: trend,
      );

  test('initial state is EarningsInitial', () {
    expect(build().state, isA<EarningsInitial>());
  });

  blocTest<EarningsBloc, EarningsState>(
    'emits [Loading, Loaded] with products sorted by profit desc',
    setUp: stubAll,
    build: build,
    act: (bloc) => bloc.add(LoadEarnings(
      startDate: start,
      endDate: end,
      granularity: TrendGranularity.month,
    )),
    expect: () => [
      isA<EarningsLoading>(),
      isA<EarningsLoaded>()
          .having((s) => s.productEarnings.map((p) => p.productId).toList(),
              'product order', [2, 3, 1])
          .having((s) => s.summary, 'summary', summary)
          .having((s) => s.wasteSummary, 'waste', waste)
          .having((s) => s.trend, 'trend', trend)
          .having((s) => s.startDate, 'startDate', start)
          .having((s) => s.endDate, 'endDate', end)
          .having((s) => s.isRefreshing, 'isRefreshing', false),
    ],
    verify: (_) {
      verify(() => getEarningsSummary(start, end)).called(1);
      verify(() => getProductEarnings(start, end)).called(1);
      verify(() => getWasteSummary(start, end)).called(1);
      verify(() => getProfitTrend(
            start: start,
            end: end,
            granularity: TrendGranularity.month,
          )).called(1);
    },
  );

  group('any failure emits EarningsError', () {
    blocTest<EarningsBloc, EarningsState>(
      'summary fails',
      setUp: () {
        stubAll();
        when(() => getEarningsSummary(any(), any())).thenAnswer(
            (_) async => const Error(DatabaseFailure('summary failed')));
      },
      build: build,
      act: (bloc) => bloc.add(LoadEarnings(startDate: start, endDate: end)),
      expect: () =>
          [isA<EarningsLoading>(), const EarningsError('summary failed')],
    );

    blocTest<EarningsBloc, EarningsState>(
      'product earnings fails',
      setUp: () {
        stubAll();
        when(() => getProductEarnings(any(), any())).thenAnswer(
            (_) async => const Error(DatabaseFailure('products failed')));
      },
      build: build,
      act: (bloc) => bloc.add(LoadEarnings(startDate: start, endDate: end)),
      expect: () =>
          [isA<EarningsLoading>(), const EarningsError('products failed')],
    );

    blocTest<EarningsBloc, EarningsState>(
      'waste fails',
      setUp: () {
        stubAll();
        when(() => getWasteSummary(any(), any())).thenAnswer(
            (_) async => const Error(DatabaseFailure('waste failed')));
      },
      build: build,
      act: (bloc) => bloc.add(LoadEarnings(startDate: start, endDate: end)),
      expect: () =>
          [isA<EarningsLoading>(), const EarningsError('waste failed')],
    );

    blocTest<EarningsBloc, EarningsState>(
      'trend fails',
      setUp: () {
        stubAll();
        when(() => getProfitTrend(
                  start: any(named: 'start'),
                  end: any(named: 'end'),
                  granularity: any(named: 'granularity'),
                ))
            .thenAnswer(
                (_) async => const Error(DatabaseFailure('trend failed')));
      },
      build: build,
      act: (bloc) => bloc.add(LoadEarnings(startDate: start, endDate: end)),
      expect: () =>
          [isA<EarningsLoading>(), const EarningsError('trend failed')],
    );
  });

  blocTest<EarningsBloc, EarningsState>(
    'refresh while loaded emits loaded.refreshing() first, then new data',
    setUp: () => stubAll(s: otherSummary),
    build: build,
    seed: () => loadedFor(start, end, summary),
    act: (bloc) =>
        bloc.add(LoadEarnings(startDate: otherStart, endDate: otherEnd)),
    expect: () => [
      loadedFor(start, end, summary).refreshing(),
      loadedFor(otherStart, otherEnd, otherSummary),
    ],
  );

  test('refreshing() keeps the data and sets isRefreshing', () {
    final r = loadedFor(start, end, summary).refreshing();
    expect(r.isRefreshing, isTrue);
    expect(r.summary, summary);
    expect(r.startDate, start);
  });

  group('stale results', () {
    late Completer<Result<EarningsSummary>> firstSummary;

    blocTest<EarningsBloc, EarningsState>(
      'drops the result of an older load that finishes after a newer one',
      setUp: () {
        stubAll();
        firstSummary = Completer<Result<EarningsSummary>>();
        when(() => getEarningsSummary(start, any()))
            .thenAnswer((_) => firstSummary.future);
        when(() => getEarningsSummary(otherStart, any()))
            .thenAnswer((_) async => const Success(otherSummary));
      },
      build: build,
      act: (bloc) async {
        bloc.add(LoadEarnings(startDate: start, endDate: end));
        await Future<void>.delayed(Duration.zero);
        bloc.add(LoadEarnings(startDate: otherStart, endDate: otherEnd));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        // The older request finishes last; its result must be ignored.
        firstSummary.complete(const Success(summary));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      expect: () => [
        isA<EarningsLoading>(),
        loadedFor(otherStart, otherEnd, otherSummary),
      ],
    );

    blocTest<EarningsBloc, EarningsState>(
      'drops a stale failure too',
      setUp: () {
        stubAll();
        firstSummary = Completer<Result<EarningsSummary>>();
        when(() => getEarningsSummary(start, any()))
            .thenAnswer((_) => firstSummary.future);
        when(() => getEarningsSummary(otherStart, any()))
            .thenAnswer((_) async => const Success(otherSummary));
      },
      build: build,
      act: (bloc) async {
        bloc.add(LoadEarnings(startDate: start, endDate: end));
        await Future<void>.delayed(Duration.zero);
        bloc.add(LoadEarnings(startDate: otherStart, endDate: otherEnd));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        firstSummary.complete(const Error(DatabaseFailure('late failure')));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      expect: () => [
        isA<EarningsLoading>(),
        loadedFor(otherStart, otherEnd, otherSummary),
      ],
    );
  });
}
