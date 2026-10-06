import 'package:equatable/equatable.dart';

import '../../domain/entities/database_info.dart';

/// What the Debug tools are doing right now.
enum DebugPhase { idle, seeding, clearing }

class DebugState extends Equatable {
  final DebugPhase phase;

  /// The last failure, kept so a row can show why a seed was rolled back.
  final String? error;

  /// Loaded on the Database page, null before it opens.
  final DatabaseInfo? info;

  const DebugState({
    this.phase = DebugPhase.idle,
    this.error,
    this.info,
  });

  bool get isBusy => phase != DebugPhase.idle;

  DebugState copyWith({
    DebugPhase? phase,
    String? error,
    bool clearError = false,
    DatabaseInfo? info,
  }) =>
      DebugState(
        phase: phase ?? this.phase,
        error: clearError ? null : (error ?? this.error),
        info: info ?? this.info,
      );

  @override
  List<Object?> get props => [phase, error, info];
}
