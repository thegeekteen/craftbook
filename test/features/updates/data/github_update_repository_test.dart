import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/updates/data/repositories/github_update_repository.dart';
import 'package:craftbook/features/updates/domain/entities/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_release_apk_updater/github_release_apk_updater.dart';
import 'package:mocktail/mocktail.dart';

class _MockUpdater extends Mock implements GithubReleaseApkUpdater {}

class _MockApi extends Mock implements GithubApiService {}

class _MockDownloader extends Mock implements ApkDownloaderService {}

const _update = AppUpdate(
  version: '1.0.5',
  notes: 'notes',
  downloadUrl: 'https://example.com/craftbook-1.0.5.apk',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockUpdater updater;
  late _MockApi api;
  late _MockDownloader downloader;
  late GithubUpdateRepository repo;

  setUp(() {
    updater = _MockUpdater();
    api = _MockApi();
    downloader = _MockDownloader();
    repo = GithubUpdateRepository(
        updater: updater, api: api, downloader: downloader);
  });

  void stubLatest(GithubAPKRelease? release) =>
      when(() => api.getLatestGithubAPKRelease(
            ownerGithub: any(named: 'ownerGithub'),
            repositoryGithub: any(named: 'repositoryGithub'),
            apkKeyName: any(named: 'apkKeyName'),
          )).thenAnswer((_) async => release);

  test('reads the latest release from this repo', () async {
    stubLatest(GithubAPKRelease(
      version: '1.0.5',
      apkUrl: 'https://example.com/craftbook-1.0.5.apk',
      releaseNote: 'notes',
    ));
    expect(await repo.latestRelease(), const Success(_update));
    verify(() => api.getLatestGithubAPKRelease(
          ownerGithub: 'thegeekteen',
          repositoryGithub: 'craftbook',
          apkKeyName: '',
        )).called(1);
  });

  test('no release is a network failure', () async {
    stubLatest(null);
    final result = await repo.latestRelease();
    expect(result, isA<Error<AppUpdate>>());
    expect((result as Error<AppUpdate>).failure, isA<NetworkFailure>());
  });

  test('download reports progress as a fraction', () async {
    when(() => downloader.downloadAPK(any(), any(), any()))
        .thenAnswer((inv) async {
      final report = inv.positionalArguments[2] as Function(int, int);
      report(50, 200);
      report(10, -1);
      return '/data/craftbook.apk';
    });
    final seen = <double?>[];
    expect(await repo.download(_update, onProgress: seen.add),
        const Success('/data/craftbook.apk'));
    expect(seen, [0.25, null]);
  });

  test('a failed download is a network failure', () async {
    when(() => downloader.downloadAPK(any(), any(), any()))
        .thenAnswer((_) async => null);
    final result = await repo.download(_update);
    expect(result, isA<Error<String>>());
  });

  test('current version is null when the platform throws', () async {
    when(() => updater.getCurrentAppVersion()).thenThrow(Exception('no'));
    expect(await repo.currentVersion(), isNull);
  });

  test('install hands the path to the plugin', () async {
    when(() => updater.installApk(any())).thenAnswer((_) async {});
    expect(await repo.install('/data/craftbook.apk'), const Success<void>(null));
    verify(() => updater.installApk('/data/craftbook.apk')).called(1);
  });
}
