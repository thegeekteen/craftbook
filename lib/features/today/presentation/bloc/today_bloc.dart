import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/get_today_dashboard.dart';
import 'today_event.dart';
import 'today_state.dart';

/// BLoC for the Today screen.
class TodayBloc extends Bloc<TodayEvent, TodayState> {
  final GetTodayDashboard getTodayDashboard;

  TodayBloc({required this.getTodayDashboard}) : super(TodayInitial()) {
    on<LoadToday>(_onLoadToday);
  }

  Future<void> _onLoadToday(LoadToday event, Emitter<TodayState> emit) async {
    // Keep showing the current dashboard during pull-to-refresh.
    if (state is! TodayLoaded) emit(TodayLoading());
    final result = await getTodayDashboard();
    switch (result) {
      case Error(:final failure):
        emit(TodayError(failure.message));
      case Success(:final value):
        emit(TodayLoaded(value));
    }
    event.done?.complete();
  }
}
