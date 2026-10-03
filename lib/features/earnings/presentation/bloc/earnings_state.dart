import 'package:equatable/equatable.dart';

import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/product_earnings.dart';
import '../../domain/entities/profit_trend.dart';

/// Base class for earnings states
abstract class EarningsState extends Equatable {
  const EarningsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class EarningsInitial extends EarningsState {}

/// First load in progress
class EarningsLoading extends EarningsState {}

/// All earnings data for [startDate]–[endDate] loaded
class EarningsLoaded extends EarningsState {
  final DateTime startDate;
  final DateTime endDate;
  final EarningsSummary summary;
  final List<ProductEarnings> productEarnings;
  final WasteSummary wasteSummary;
  final List<TrendBucket> trend;

  /// A different period is loading; the current numbers stay visible.
  final bool isRefreshing;

  const EarningsLoaded({
    required this.startDate,
    required this.endDate,
    required this.summary,
    required this.productEarnings,
    required this.wasteSummary,
    this.trend = const [],
    this.isRefreshing = false,
  });

  EarningsLoaded refreshing() => EarningsLoaded(
        startDate: startDate,
        endDate: endDate,
        summary: summary,
        productEarnings: productEarnings,
        wasteSummary: wasteSummary,
        trend: trend,
        isRefreshing: true,
      );

  @override
  List<Object?> get props =>
      [startDate, endDate, summary, productEarnings, wasteSummary, trend, isRefreshing];
}

/// Error occurred while loading earnings data
class EarningsError extends EarningsState {
  final String message;

  const EarningsError(this.message);

  @override
  List<Object?> get props => [message];
}
