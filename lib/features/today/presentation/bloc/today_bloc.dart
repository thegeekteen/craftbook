import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../orders/domain/entities/order.dart';
import '../../domain/usecases/get_alert_summary.dart';
import '../../domain/usecases/get_today_orders.dart';
import 'today_event.dart';
import 'today_state.dart';

/// BLoC for the today screen.
///
/// Loads today's orders and the alert summary (low stock count, etc.).
class TodayBloc extends Bloc<TodayEvent, TodayState> {
  final GetTodayOrders getTodayOrders;
  final GetAlertSummary getAlertSummary;

  // Holds partial results while loading both orders and alerts
  List<Order>? _orders;
  AlertSummary? _alertSummary;

  TodayBloc({
    required this.getTodayOrders,
    required this.getAlertSummary,
  }) : super(TodayInitial()) {
    on<LoadToday>(_onLoadToday);
    on<LoadAlerts>(_onLoadAlerts);
  }

  Future<void> _onLoadToday(
    LoadToday event,
    Emitter<TodayState> emit,
  ) async {
    emit(TodayLoading());
    _orders = null;
    _alertSummary = null;

    final result = await getTodayOrders();
    result.fold(
      (failure) => emit(TodayError(failure.message)),
      (orders) {
        _orders = orders;
        // Trigger alert loading
        add(LoadAlerts());
      },
    );
  }

  Future<void> _onLoadAlerts(
    LoadAlerts event,
    Emitter<TodayState> emit,
  ) async {
    final result = await getAlertSummary();
    result.fold(
      (failure) => emit(TodayError(failure.message)),
      (alertSummary) {
        _alertSummary = alertSummary;
        if (_orders != null) {
          emit(TodayLoaded(
            orders: _orders!,
            alertSummary: _alertSummary!,
          ));
        }
      },
    );
  }
}
