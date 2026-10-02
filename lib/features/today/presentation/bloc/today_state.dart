import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order.dart';
import '../../domain/usecases/get_alert_summary.dart';

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

/// Today's orders and alerts loaded successfully
class TodayLoaded extends TodayState {
  final List<Order> orders;
  final AlertSummary alertSummary;

  const TodayLoaded({
    required this.orders,
    required this.alertSummary,
  });

  @override
  List<Object?> get props => [orders, alertSummary];
}

/// Error occurred while loading today's data
class TodayError extends TodayState {
  final String message;

  const TodayError(this.message);

  @override
  List<Object?> get props => [message];
}
