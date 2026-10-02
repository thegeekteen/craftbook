import 'package:equatable/equatable.dart';

/// Base class for today events
abstract class TodayEvent extends Equatable {
  const TodayEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's orders
class LoadToday extends TodayEvent {}

/// Load alert summary (low stock, blocked products/orders)
class LoadAlerts extends TodayEvent {}
