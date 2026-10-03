import 'dart:async';

import 'package:equatable/equatable.dart';

/// Base class for today events
abstract class TodayEvent extends Equatable {
  const TodayEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the dashboard. [done] completes when loading finishes,
/// so pull-to-refresh can stop its spinner.
class LoadToday extends TodayEvent {
  final Completer<void>? done;

  LoadToday({this.done});
}
