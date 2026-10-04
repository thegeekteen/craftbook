import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/repositories/update_repository.dart';
import '../../domain/usecases/check_for_update.dart';
import '../../domain/usecases/install_update.dart';
import 'update_state.dart';

/// Checks GitHub for a newer build and installs it. Never runs on its own:
/// the app stays offline until the user taps "Check for updates".
class UpdateCubit extends Cubit<UpdateState> {
  final UpdateRepository repository;
  final CheckForUpdate checkForUpdate;
  final InstallUpdate installUpdate;

  UpdateCubit({
    required this.repository,
    required this.checkForUpdate,
    required this.installUpdate,
  }) : super(const UpdateState());

  Future<void> load() async {
    final version = await repository.currentVersion();
    if (!isClosed) emit(state.copyWith(currentVersion: version));
  }

  Future<void> check() async {
    if (_busy) return;
    emit(state.copyWith(status: UpdateStatus.checking));
    final result = await checkForUpdate();
    if (isClosed) return;
    switch (result) {
      case Error(:final failure):
        emit(state.copyWith(
            status: UpdateStatus.failed, error: failure.message));
      case Success(value: final update?):
        emit(state.copyWith(status: UpdateStatus.available, update: update));
      case Success():
        emit(state.copyWith(status: UpdateStatus.upToDate));
    }
  }

  Future<void> install() async {
    final update = state.update;
    if (update == null || _busy) return;
    emit(state.copyWith(status: UpdateStatus.downloading));
    final result = await installUpdate(update, onProgress: _onProgress);
    if (isClosed) return;
    switch (result) {
      case Error(:final failure):
        emit(state.copyWith(
            status: UpdateStatus.failed, error: failure.message));
      case Success():
        // Android's installer is up now. If they back out of it, the row
        // offers the same update again.
        emit(state.copyWith(status: UpdateStatus.available));
    }
  }

  bool get _busy =>
      state.status == UpdateStatus.checking ||
      state.status == UpdateStatus.downloading;

  /// The downloader reports every chunk; only whole-percent steps redraw.
  void _onProgress(double? progress) {
    if (isClosed || state.status != UpdateStatus.downloading) return;
    final step = progress == null ? null : (progress * 100).floor() / 100;
    if (step == state.progress) return;
    emit(state.copyWith(status: UpdateStatus.downloading, progress: step));
  }
}
