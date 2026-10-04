import '../../../../core/error/result.dart';
import '../entities/app_update.dart';
import '../repositories/update_repository.dart';
import '../version_compare.dart';

/// The latest release if it's newer than what's installed, otherwise null.
class CheckForUpdate {
  final UpdateRepository repository;

  CheckForUpdate(this.repository);

  Future<Result<AppUpdate?>> call() async {
    final latest = await repository.latestRelease();
    switch (latest) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        // An unknown installed version offers the update rather than hiding it.
        final current = await repository.currentVersion();
        final newer = current == null || isNewerVersion(value.version, current);
        return Success(newer ? value : null);
    }
  }
}
