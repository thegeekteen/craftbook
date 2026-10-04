import '../../../../core/error/result.dart';
import '../entities/app_update.dart';

/// Where new builds of the app are published. The only thing in the app that
/// goes online, and only when the user asks it to.
abstract class UpdateRepository {
  /// The installed version, or null if the platform couldn't say.
  Future<String?> currentVersion();

  /// The newest published release, whatever its version.
  Future<Result<AppUpdate>> latestRelease();

  /// Downloads [update]'s APK and returns its local path. [onProgress] gets a
  /// 0–1 fraction, or null while the size is unknown.
  Future<Result<String>> download(
    AppUpdate update, {
    void Function(double? progress)? onProgress,
  });

  /// Hands the APK at [path] to Android's installer.
  Future<Result<void>> install(String path);
}
