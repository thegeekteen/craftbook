import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/product_earnings.dart';
import '../../domain/usecases/get_earnings_summary.dart';
import '../../domain/usecases/get_product_earnings.dart';
import '../../domain/usecases/get_waste_summary.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

/// BLoC for the earnings overview screen.
///
/// Loads three data sets in parallel: overall summary, per-product earnings,
/// and waste summary. Emits [EarningsLoaded] once all three are available.
class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final GetEarningsSummary getEarningsSummary;
  final GetProductEarnings getProductEarnings;
  final GetWasteSummary getWasteSummary;

  // Holds partial results while loading all three data sets
  EarningsSummary? _summary;
  List<ProductEarnings>? _productEarnings;
  WasteSummary? _wasteSummary;

  EarningsBloc({
    required this.getEarningsSummary,
    required this.getProductEarnings,
    required this.getWasteSummary,
  }) : super(EarningsInitial()) {
    on<LoadEarnings>(_onLoadEarnings);
    on<LoadProductEarnings>(_onLoadProductEarnings);
    on<LoadWasteSummary>(_onLoadWasteSummary);
  }

  Future<void> _onLoadEarnings(
    LoadEarnings event,
    Emitter<EarningsState> emit,
  ) async {
    emit(EarningsLoading());
    _summary = null;
    _productEarnings = null;
    _wasteSummary = null;

    final result = await getEarningsSummary(event.startDate, event.endDate);
    switch (result) {
      case Error(:final failure):
        emit(EarningsError(failure.message));
      case Success(:final value):
        _summary = value;
        // Trigger loading of product earnings and waste summary
        add(LoadProductEarnings(
          startDate: event.startDate,
          endDate: event.endDate,
        ));
        add(LoadWasteSummary(
          startDate: event.startDate,
          endDate: event.endDate,
        ));
    }
  }

  Future<void> _onLoadProductEarnings(
    LoadProductEarnings event,
    Emitter<EarningsState> emit,
  ) async {
    final result =
        await getProductEarnings(event.startDate, event.endDate);
    switch (result) {
      case Error(:final failure):
        emit(EarningsError(failure.message));
      case Success(:final value):
        _productEarnings = value;
        _tryEmitLoaded(emit);
    }
  }

  Future<void> _onLoadWasteSummary(
    LoadWasteSummary event,
    Emitter<EarningsState> emit,
  ) async {
    final result =
        await getWasteSummary(event.startDate, event.endDate);
    switch (result) {
      case Error(:final failure):
        emit(EarningsError(failure.message));
      case Success(:final value):
        _wasteSummary = value;
        _tryEmitLoaded(emit);
    }
  }

  /// Emit [EarningsLoaded] once all three data sets are available.
  void _tryEmitLoaded(Emitter<EarningsState> emit) {
    if (_summary != null && _productEarnings != null && _wasteSummary != null) {
      emit(EarningsLoaded(
        summary: _summary!,
        productEarnings: _productEarnings!,
        wasteSummary: _wasteSummary!,
      ));
    }
  }
}
