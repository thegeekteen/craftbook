import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/product_earnings.dart';
import '../../domain/entities/profit_trend.dart';
import '../../domain/usecases/get_earnings_summary.dart';
import '../../domain/usecases/get_product_earnings.dart';
import '../../domain/usecases/get_profit_trend.dart';
import '../../domain/usecases/get_waste_summary.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

/// BLoC for the Money screen.
class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final GetEarningsSummary getEarningsSummary;
  final GetProductEarnings getProductEarnings;
  final GetWasteSummary getWasteSummary;
  final GetProfitTrend getProfitTrend;

  /// The most recent request; results for older ones are dropped so quick
  /// period changes can't show stale numbers.
  LoadEarnings? _latest;

  EarningsBloc({
    required this.getEarningsSummary,
    required this.getProductEarnings,
    required this.getWasteSummary,
    required this.getProfitTrend,
  }) : super(EarningsInitial()) {
    on<LoadEarnings>(_onLoadEarnings);
  }

  Future<void> _onLoadEarnings(
    LoadEarnings event,
    Emitter<EarningsState> emit,
  ) async {
    _latest = event;
    final current = state;
    emit(current is EarningsLoaded ? current.refreshing() : EarningsLoading());

    final start = event.startDate;
    final end = event.endDate;
    final results = await Future.wait([
      getEarningsSummary(start, end),
      getProductEarnings(start, end),
      getWasteSummary(start, end),
      getProfitTrend(start: start, end: end, granularity: event.granularity),
    ]);
    if (!identical(event, _latest)) return;

    for (final r in results) {
      if (r case Error(:final failure)) {
        emit(EarningsError(failure.message));
        return;
      }
    }

    final products = [...(results[1] as Success<List<ProductEarnings>>).value]
      ..sort((a, b) => b.totalProfit.compareTo(a.totalProfit));
    emit(EarningsLoaded(
      startDate: start,
      endDate: end,
      summary: (results[0] as Success<EarningsSummary>).value,
      productEarnings: products,
      wasteSummary: (results[2] as Success<WasteSummary>).value,
      trend: (results[3] as Success<List<TrendBucket>>).value,
    ));
  }
}
