import 'package:equatable/equatable.dart';

import '../../domain/entities/profit_trend.dart';

/// Base class for earnings events
abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

/// Load everything the Money screen shows for one period.
class LoadEarnings extends EarningsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final TrendGranularity granularity;

  const LoadEarnings({
    required this.startDate,
    required this.endDate,
    this.granularity = TrendGranularity.day,
  });

  @override
  List<Object?> get props => [startDate, endDate, granularity];
}
