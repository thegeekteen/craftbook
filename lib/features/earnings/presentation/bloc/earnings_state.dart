import 'package:equatable/equatable.dart';

import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/product_earnings.dart';

/// Base class for earnings states
abstract class EarningsState extends Equatable {
  const EarningsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class EarningsInitial extends EarningsState {}

/// Earnings data is being loaded
class EarningsLoading extends EarningsState {}

/// All earnings data loaded successfully
class EarningsLoaded extends EarningsState {
  final EarningsSummary summary;
  final List<ProductEarnings> productEarnings;
  final WasteSummary wasteSummary;

  const EarningsLoaded({
    required this.summary,
    required this.productEarnings,
    required this.wasteSummary,
  });

  @override
  List<Object?> get props => [summary, productEarnings, wasteSummary];
}

/// Error occurred while loading earnings data
class EarningsError extends EarningsState {
  final String message;

  const EarningsError(this.message);

  @override
  List<Object?> get props => [message];
}
