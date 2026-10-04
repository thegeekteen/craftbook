import '../../../../core/error/result.dart';
import '../entities/app_update.dart';
import '../repositories/update_repository.dart';

/// Downloads [AppUpdate]'s APK and opens Android's installer on it.
class InstallUpdate {
  final UpdateRepository repository;

  InstallUpdate(this.repository);

  Future<Result<void>> call(
    AppUpdate update, {
    void Function(double? progress)? onProgress,
  }) async {
    final downloaded =
        await repository.download(update, onProgress: onProgress);
    switch (downloaded) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        return repository.install(value);
    }
  }
}
