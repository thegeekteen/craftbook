import 'dart:io';

import 'package:github_release_apk_updater/github_release_apk_updater.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_update.dart';
import '../../domain/repositories/update_repository.dart';

/// Releases published by the GitHub workflow in `.github/workflows/`.
class GithubUpdateRepository implements UpdateRepository {
  static const owner = 'thegeekteen';
  static const repo = 'craftbook';

  final GithubReleaseApkUpdater _updater;
  final GithubApiService _api;
  final ApkDownloaderService _downloader;

  GithubUpdateRepository({
    GithubReleaseApkUpdater? updater,
    GithubApiService? api,
    ApkDownloaderService? downloader,
  })  : _updater = updater ?? GithubReleaseApkUpdater(),
        _api = api ?? GithubApiService(),
        _downloader = downloader ?? ApkDownloaderService();

  @override
  Future<String?> currentVersion() async {
    try {
      return await _updater.getCurrentAppVersion();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<AppUpdate>> latestRelease() async {
    // The plugin folds every failure (offline, no release yet, no APK
    // attached) into null, so one message has to cover them all.
    final release = await _api.getLatestGithubAPKRelease(
      ownerGithub: owner,
      repositoryGithub: repo,
      apkKeyName: '',
    );
    if (release == null) {
      return const Error(NetworkFailure(
          "Couldn't check for updates. Check your internet and try again."));
    }
    return Success(AppUpdate(
      version: release.version,
      notes: release.releaseNote,
      downloadUrl: release.apkUrl,
    ));
  }

  @override
  Future<Result<String>> download(
    AppUpdate update, {
    void Function(double? progress)? onProgress,
  }) async {
    await _deleteOldDownloads();
    final path = await _downloader.downloadAPK(
      update.downloadUrl,
      null,
      (received, total) =>
          onProgress?.call(total > 0 ? received / total : null),
    );
    if (path == null) {
      return const Error(NetworkFailure(
          "The download didn't finish. Check your internet and try again."));
    }
    return Success(path);
  }

  @override
  Future<Result<void>> install(String path) async {
    try {
      await _updater.installApk(path);
      return const Success(null);
    } catch (e) {
      return const Error(UnexpectedFailure("Couldn't open the installer."));
    }
  }

  /// Each APK is tens of MB and lands in the same folder, so drop the ones
  /// from earlier updates before fetching the next.
  Future<void> _deleteOldDownloads() async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return;
      await for (final file in dir.list()) {
        if (file is File && file.path.endsWith('.apk')) await file.delete();
      }
    } catch (_) {
      // Only housekeeping; a leftover file doesn't stop the update.
    }
  }
}
