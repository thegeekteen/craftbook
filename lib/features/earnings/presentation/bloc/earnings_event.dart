import 'package:equatable/equatable.dart';

/// Base class for earnings events
abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the overall earnings summary for a date range
class LoadEarnings extends EarningsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadEarnings({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Load per-product earnings for a date range
class LoadProductEarnings extends EarningsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadProductEarnings({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Load the waste summary for a date range
class LoadWasteSummary extends EarningsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadWasteSummary({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
