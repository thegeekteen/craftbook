import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/debug/domain/entities/database_info.dart';
import 'package:craftbook/features/debug/domain/entities/seed_outcome.dart';
import 'package:craftbook/features/debug/domain/usecases/clear_shop_data.dart';
import 'package:craftbook/features/debug/domain/usecases/get_database_info.dart';
import 'package:craftbook/features/debug/domain/usecases/seed_fake_shop.dart';
import 'package:craftbook/features/debug/presentation/bloc/debug_cubit.dart';
import 'package:craftbook/features/debug/presentation/bloc/debug_state.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSeedFakeShop extends Mock implements SeedFakeShop {}

T _ok<T>(Result<T> result) => switch (result) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

void main() {
  late AppDatabase db;

  setUp(() async {
    await getIt.reset();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await configureDependencies(database: db);
  });

  tearDown(() async {
    await db.close();
    await getIt.reset();
  });

  /// The cubit under test always gets the real use cases against the in-memory
  /// database — seeding it costs about a second, and a cubit wired to a fake
  /// repository would prove nothing about the order the results arrive in.
  DebugCubit buildCubit({SeedFakeShop? seeder}) => DebugCubit(
        seedFakeShop: seeder ?? getIt<SeedFakeShop>(),
        clearShopData: getIt<ClearShopData>(),
        getDatabaseInfo: getIt<GetDatabaseInfo>(),
      );

  group('DebugCubit', () {
    blocTest<DebugCubit, DebugState>(
      'seed reports the shop it built and covers every option',
      build: buildCubit,
      act: (cubit) => cubit.seed(),
      expect: () => const [
        DebugState(phase: DebugPhase.seeding),
        DebugState(),
      ],
      verify: (_) async {
        final orders = _ok(await getIt<OrderRepository>().getAllOrders());
        expect(orders, isNotEmpty);
      },
    );

    test('seed hands back the outcome it wrote', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final result = await cubit.seed();
      final outcome = _ok(result);

      expect(outcome.coverage.gaps, isEmpty);
      expect(outcome.orders, greaterThan(20));
      expect(cubit.state, const DebugState());
    });

    blocTest<DebugCubit, DebugState>(
      'clear goes through clearing and back to idle',
      build: buildCubit,
      act: (cubit) async {
        _ok(await getIt<SeedFakeShop>()());
        await cubit.clear();
      },
      expect: () => const [
        DebugState(phase: DebugPhase.clearing),
        DebugState(),
      ],
      verify: (_) async {
        expect(_ok(await getIt<OrderRepository>().getAllOrders()), isEmpty);
      },
    );

    blocTest<DebugCubit, DebugState>(
      'a refused seed leaves its reason on the state',
      build: () {
        final seeder = _MockSeedFakeShop();
        when(() => seeder(seed: any(named: 'seed'))).thenAnswer(
            (_) async => const Error<SeedOutcome>(ValidationFailure('nope')));
        return buildCubit(seeder: seeder);
      },
      act: (cubit) => cubit.seed(),
      expect: () => const [
        DebugState(phase: DebugPhase.seeding),
        DebugState(error: 'nope'),
      ],
    );

    test('a run started while another is going is refused', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final seeding = cubit.seed();
      expect(cubit.state.phase, DebugPhase.seeding);
      expect(await cubit.seed(),
          const Error<SeedOutcome>(ValidationFailure('Already working.')));
      expect(await cubit.clear(),
          const Error<void>(ValidationFailure('Already working.')));

      _ok(await seeding);
      expect(cubit.state, const DebugState());
    });

    blocTest<DebugCubit, DebugState>(
      'loadInfo stores the database info on the state',
      build: buildCubit,
      act: (cubit) => cubit.loadInfo(),
      expect: () => [
        predicate<DebugState>(
            (state) => state.info is DatabaseInfo, 'carries a DatabaseInfo'),
      ],
      verify: (cubit) {
        final info = cubit.state.info!;
        expect(info.schemaVersion, AppDatabase.currentSchemaVersion);
        expect(info.tableCounts, contains('orders'));
        expect(info.totalRows, greaterThan(0));
      },
    );
  });
}
