import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/updates/domain/entities/app_update.dart';
import 'package:craftbook/features/updates/domain/repositories/update_repository.dart';
import 'package:craftbook/features/updates/domain/usecases/check_for_update.dart';
import 'package:craftbook/features/updates/domain/usecases/install_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements UpdateRepository {}

const _release = AppUpdate(
  version: '1.0.5',
  notes: '- Faster',
  downloadUrl: 'https://example.com/craftbook-1.0.5.apk',
);

void main() {
  late _MockRepo repo;

  setUpAll(() => registerFallbackValue(_release));
  setUp(() => repo = _MockRepo());

  group('CheckForUpdate', () {
    test('returns the release when it is newer', () async {
      when(() => repo.latestRelease())
          .thenAnswer((_) async => const Success(_release));
      when(() => repo.currentVersion()).thenAnswer((_) async => '1.0.4');
      expect(await CheckForUpdate(repo)(), const Success<AppUpdate?>(_release));
    });

    test('returns null when already on that version', () async {
      when(() => repo.latestRelease())
          .thenAnswer((_) async => const Success(_release));
      when(() => repo.currentVersion()).thenAnswer((_) async => '1.0.5');
      expect(await CheckForUpdate(repo)(), const Success<AppUpdate?>(null));
    });

    test('offers the release when the installed version is unknown', () async {
      when(() => repo.latestRelease())
          .thenAnswer((_) async => const Success(_release));
      when(() => repo.currentVersion()).thenAnswer((_) async => null);
      expect(await CheckForUpdate(repo)(), const Success<AppUpdate?>(_release));
    });

    test('passes on a failed lookup', () async {
      when(() => repo.latestRelease())
          .thenAnswer((_) async => const Error(NetworkFailure('offline')));
      expect(await CheckForUpdate(repo)(),
          const Error<AppUpdate?>(NetworkFailure('offline')));
      verifyNever(() => repo.currentVersion());
    });
  });

  group('InstallUpdate', () {
    test('downloads, then installs the downloaded file', () async {
      when(() => repo.download(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((_) async => const Success('/tmp/craftbook.apk'));
      when(() => repo.install(any()))
          .thenAnswer((_) async => const Success(null));
      expect(await InstallUpdate(repo)(_release), const Success<void>(null));
      verify(() => repo.install('/tmp/craftbook.apk')).called(1);
    });

    test('forwards download progress', () async {
      when(() => repo.download(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((inv) async {
        final report =
            inv.namedArguments[#onProgress] as void Function(double?);
        report(0.5);
        return const Success('/tmp/craftbook.apk');
      });
      when(() => repo.install(any()))
          .thenAnswer((_) async => const Success(null));
      final seen = <double?>[];
      await InstallUpdate(repo)(_release, onProgress: seen.add);
      expect(seen, [0.5]);
    });

    test('does not install after a failed download', () async {
      when(() => repo.download(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((_) async => const Error(NetworkFailure('dropped')));
      expect(await InstallUpdate(repo)(_release),
          const Error<void>(NetworkFailure('dropped')));
      verifyNever(() => repo.install(any()));
    });
  });
}
