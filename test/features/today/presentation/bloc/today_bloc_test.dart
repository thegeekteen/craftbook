import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:craftbook/features/notes/domain/usecases/get_pinned_notes.dart';
import 'package:craftbook/features/today/domain/usecases/get_alert_summary.dart';
import 'package:craftbook/features/today/domain/usecases/get_today_dashboard.dart';
import 'package:craftbook/features/today/presentation/bloc/today_bloc.dart';
import 'package:craftbook/features/today/presentation/bloc/today_event.dart';
import 'package:craftbook/features/today/presentation/bloc/today_state.dart';

class MockGetTodayDashboard extends Mock implements GetTodayDashboard {}

class MockGetPinnedNotes extends Mock implements GetPinnedNotes {}

void main() {
  late MockGetTodayDashboard getTodayDashboard;
  late MockGetPinnedNotes getPinnedNotes;

  const alerts = AlertSummary(lowStockCount: 0, materialNames: []);
  const dashboard = TodayDashboard(
    due: [],
    placedToday: [],
    alerts: alerts,
    weekProfit: 120,
  );
  const updatedDashboard = TodayDashboard(
    due: [],
    placedToday: [],
    alerts: alerts,
    weekProfit: 300,
  );

  setUp(() {
    getTodayDashboard = MockGetTodayDashboard();
    getPinnedNotes = MockGetPinnedNotes();
    when(() => getPinnedNotes())
        .thenAnswer((_) async => const Success(<Note>[]));
  });

  TodayBloc build() => TodayBloc(
        getTodayDashboard: getTodayDashboard,
        getPinnedNotes: getPinnedNotes,
      );

  test('initial state is TodayInitial', () {
    expect(build().state, isA<TodayInitial>());
  });

  blocTest<TodayBloc, TodayState>(
    'emits [TodayLoading, TodayLoaded] on success',
    setUp: () => when(() => getTodayDashboard())
        .thenAnswer((_) async => const Success(dashboard)),
    build: build,
    act: (bloc) => bloc.add(const LoadToday()),
    expect: () => [isA<TodayLoading>(), const TodayLoaded(dashboard)],
    verify: (_) => verify(() => getTodayDashboard()).called(1),
  );

  blocTest<TodayBloc, TodayState>(
    'emits [TodayLoading, TodayError] on failure',
    setUp: () => when(() => getTodayDashboard())
        .thenAnswer((_) async => const Error(DatabaseFailure('db down'))),
    build: build,
    act: (bloc) => bloc.add(const LoadToday()),
    expect: () => [isA<TodayLoading>(), const TodayError('db down')],
  );

  blocTest<TodayBloc, TodayState>(
    'reload while loaded does not emit TodayLoading again',
    setUp: () => when(() => getTodayDashboard())
        .thenAnswer((_) async => const Success(updatedDashboard)),
    build: build,
    seed: () => const TodayLoaded(dashboard),
    act: (bloc) => bloc.add(const LoadToday()),
    expect: () => [const TodayLoaded(updatedDashboard)],
  );

  blocTest<TodayBloc, TodayState>(
    'reload failure while loaded emits only TodayError',
    setUp: () => when(() => getTodayDashboard())
        .thenAnswer((_) async => const Error(DatabaseFailure('oops'))),
    build: build,
    seed: () => const TodayLoaded(dashboard),
    act: (bloc) => bloc.add(const LoadToday()),
    expect: () => [const TodayError('oops')],
  );

  group('pinned notes', () {
    const pinned = [Note(id: 1, title: 'Supplier', isPinned: true)];

    blocTest<TodayBloc, TodayState>(
      'are loaded alongside the dashboard',
      setUp: () {
        when(() => getTodayDashboard())
            .thenAnswer((_) async => const Success(dashboard));
        when(() => getPinnedNotes())
            .thenAnswer((_) async => const Success(pinned));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadToday()),
      expect: () => [
        isA<TodayLoading>(),
        const TodayLoaded(dashboard, pinnedNotes: pinned)
      ],
    );

    blocTest<TodayBloc, TodayState>(
      'failing to load them is reported, not hidden',
      setUp: () {
        when(() => getTodayDashboard())
            .thenAnswer((_) async => const Success(dashboard));
        when(() => getPinnedNotes()).thenAnswer(
            (_) async => const Error(DatabaseFailure('notes down')));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadToday()),
      expect: () => [isA<TodayLoading>(), const TodayError('notes down')],
    );
  });

  group('done completer', () {
    test('completes after a successful load', () async {
      when(() => getTodayDashboard())
          .thenAnswer((_) async => const Success(dashboard));
      final bloc = build();
      final done = Completer<void>();
      bloc.add(LoadToday(done: done));
      await done.future.timeout(const Duration(seconds: 1));
      expect(done.isCompleted, isTrue);
      expect(bloc.state, const TodayLoaded(dashboard));
      await bloc.close();
    });

    test('completes after a failed load', () async {
      when(() => getTodayDashboard())
          .thenAnswer((_) async => const Error(DatabaseFailure('nope')));
      final bloc = build();
      final done = Completer<void>();
      bloc.add(LoadToday(done: done));
      await done.future.timeout(const Duration(seconds: 1));
      expect(bloc.state, const TodayError('nope'));
      await bloc.close();
    });
  });
}
