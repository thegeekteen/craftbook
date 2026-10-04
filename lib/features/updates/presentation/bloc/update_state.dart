import 'package:equatable/equatable.dart';

import '../../domain/entities/app_update.dart';

enum UpdateStatus { idle, checking, upToDate, available, downloading, failed }

class UpdateState extends Equatable {
  final UpdateStatus status;

  /// Installed version; null until loaded or if the platform couldn't say.
  final String? currentVersion;

  /// Set once a newer release is found, and kept through download failures
  /// so a retry doesn't have to check again.
  final AppUpdate? update;

  /// 0–1 while downloading; null when the size is unknown.
  final double? progress;

  final String? error;

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.currentVersion,
    this.update,
    this.progress,
    this.error,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    String? currentVersion,
    AppUpdate? update,
    double? progress,
    String? error,
  }) =>
      UpdateState(
        status: status ?? this.status,
        currentVersion: currentVersion ?? this.currentVersion,
        update: update ?? this.update,
        // Progress and error only mean something for the state they came with.
        progress: progress,
        error: error,
      );

  @override
  List<Object?> get props => [status, currentVersion, update, progress, error];
}
