import 'package:equatable/equatable.dart';

import '../../domain/usecases/get_today_dashboard.dart';

/// Base class for today states
abstract class TodayState extends Equatable {
  const TodayState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class TodayInitial extends TodayState {}

/// Today's data is being loaded
class TodayLoading extends TodayState {}

/// Dashboard loaded successfully
class TodayLoaded extends TodayState {
  final TodayDashboard dashboard;

  const TodayLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

/// Error occurred while loading today's data
class TodayError extends TodayState {
  final String message;

  const TodayError(this.message);

  @override
  List<Object?> get props => [message];
}
