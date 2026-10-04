import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../notes/domain/usecases/get_pinned_notes.dart';
import '../../domain/usecases/get_today_dashboard.dart';
import 'today_event.dart';
import 'today_state.dart';

/// BLoC for the Today screen.
class TodayBloc extends Bloc<TodayEvent, TodayState> {
  final GetTodayDashboard getTodayDashboard;
  final GetPinnedNotes getPinnedNotes;

  TodayBloc({
    required this.getTodayDashboard,
    required this.getPinnedNotes,
  }) : super(TodayInitial()) {
    on<LoadToday>(_onLoadToday);
  }

  Future<void> _onLoadToday(LoadToday event, Emitter<TodayState> emit) async {
    // Keep showing the current dashboard during pull-to-refresh.
    if (state is! TodayLoaded) emit(TodayLoading());
    final result = await getTodayDashboard();
    final notes = await getPinnedNotes();
    switch ((result, notes)) {
      case (Error(:final failure), _) || (_, Error(:final failure)):
        emit(TodayError(failure.message));
      case (Success(value: final dashboard), Success(value: final pinned)):
        emit(TodayLoaded(dashboard, pinnedNotes: pinned));
    }
    event.done?.complete();
  }
}
