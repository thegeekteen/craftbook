import 'package:equatable/equatable.dart';

import '../../../notes/domain/entities/note.dart';
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

  /// Notes pinned to Today, most recently edited first.
  final List<Note> pinnedNotes;

  const TodayLoaded(this.dashboard, {this.pinnedNotes = const []});

  @override
  List<Object?> get props => [dashboard, pinnedNotes];
}

/// Error occurred while loading today's data
class TodayError extends TodayState {
  final String message;

  const TodayError(this.message);

  @override
  List<Object?> get props => [message];
}
