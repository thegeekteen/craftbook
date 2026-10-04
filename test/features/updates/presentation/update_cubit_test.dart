import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/updates/domain/entities/app_update.dart';
import 'package:craftbook/features/updates/domain/repositories/update_repository.dart';
import 'package:craftbook/features/updates/domain/usecases/check_for_update.dart';
import 'package:craftbook/features/updates/domain/usecases/install_update.dart';
import 'package:craftbook/features/updates/presentation/bloc/update_cubit.dart';
import 'package:craftbook/features/updates/presentation/bloc/update_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements UpdateRepository {}

class _MockCheck extends Mock implements CheckForUpdate {}

class _MockInstall extends Mock implements InstallUpdate {}

const _update = AppUpdate(
  version: '1.0.5',
  notes: '',
  downloadUrl: 'https://example.com/craftbook-1.0.5.apk',
);

void main() {
  late _MockRepo repo;
  late _MockCheck check;
  late _MockInstall install;

  setUpAll(() => registerFallbackValue(_update));

  setUp(() {
    repo = _MockRepo();
    check = _MockCheck();
    install = _MockInstall();
  });

  UpdateCubit build() => UpdateCubit(
        repository: repo,
        checkForUpdate: check,
        installUpdate: install,
      );

  const available =
      UpdateState(status: UpdateStatus.available, update: _update);

  blocTest<UpdateCubit, UpdateState>(
    'load reads the installed version',
    build: () {
      when(() => repo.currentVersion()).thenAnswer((_) async => '1.0.4');
      return build();
    },
    act: (c) => c.load(),
    expect: () => [const UpdateState(currentVersion: '1.0.4')],
  );

  blocTest<UpdateCubit, UpdateState>(
    'check finds a newer release',
    build: () {
      when(() => check()).thenAnswer((_) async => const Success(_update));
      return build();
    },
    act: (c) => c.check(),
    expect: () => [
      const UpdateState(status: UpdateStatus.checking),
      available,
    ],
  );

  blocTest<UpdateCubit, UpdateState>(
    'check says when already up to date',
    build: () {
      when(() => check()).thenAnswer((_) async => const Success(null));
      return build();
    },
    act: (c) => c.check(),
    expect: () => [
      const UpdateState(status: UpdateStatus.checking),
      const UpdateState(status: UpdateStatus.upToDate),
    ],
  );

  blocTest<UpdateCubit, UpdateState>(
    'check reports a failure',
    build: () {
      when(() => check())
          .thenAnswer((_) async => const Error(NetworkFailure('offline')));
      return build();
    },
    act: (c) => c.check(),
    expect: () => [
      const UpdateState(status: UpdateStatus.checking),
      const UpdateState(status: UpdateStatus.failed, error: 'offline'),
    ],
  );

  blocTest<UpdateCubit, UpdateState>(
    'install shows whole-percent progress, then offers the update again',
    build: () {
      when(() => install(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((inv) async {
        final report =
            inv.namedArguments[#onProgress] as void Function(double?);
        report(0.501);
        report(0.509); // same percent: no redraw
        report(1);
        return const Success(null);
      });
      return build();
    },
    seed: () => available,
    act: (c) => c.install(),
    expect: () => [
      const UpdateState(status: UpdateStatus.downloading, update: _update),
      const UpdateState(
          status: UpdateStatus.downloading, update: _update, progress: 0.5),
      const UpdateState(
          status: UpdateStatus.downloading, update: _update, progress: 1),
      available,
    ],
  );

  blocTest<UpdateCubit, UpdateState>(
    'a failed install keeps the update for a retry',
    build: () {
      when(() => install(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((_) async => const Error(NetworkFailure('dropped')));
      return build();
    },
    seed: () => available,
    act: (c) => c.install(),
    expect: () => [
      const UpdateState(status: UpdateStatus.downloading, update: _update),
      const UpdateState(
          status: UpdateStatus.failed, update: _update, error: 'dropped'),
    ],
  );

  blocTest<UpdateCubit, UpdateState>(
    'install does nothing without an update',
    build: build,
    act: (c) => c.install(),
    expect: () => <UpdateState>[],
  );

  blocTest<UpdateCubit, UpdateState>(
    'ignores a second check while one is running',
    build: () {
      when(() => check()).thenAnswer((_) async => const Success(null));
      return build();
    },
    act: (c) {
      c.check();
      c.check();
    },
    expect: () => [
      const UpdateState(status: UpdateStatus.checking),
      const UpdateState(status: UpdateStatus.upToDate),
    ],
    verify: (_) => verify(() => check()).called(1),
  );
}
