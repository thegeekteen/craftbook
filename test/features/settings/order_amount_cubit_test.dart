import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/settings/domain/entities/order_amount_shown.dart';
import 'package:craftbook/features/settings/domain/repositories/settings_repository.dart';
import 'package:craftbook/features/settings/presentation/bloc/order_amount_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late _MockSettings repo;

  setUpAll(() => registerFallbackValue(OrderAmountShown.total));

  setUp(() {
    repo = _MockSettings();
    when(() => repo.setOrderAmountShown(any())).thenAnswer((_) async => const Success(null));
  });

  test('starts on the order total', () {
    expect(OrderAmountCubit(repo).state, OrderAmountShown.total);
  });

  blocTest<OrderAmountCubit, OrderAmountShown>(
    'load emits the stored choice',
    build: () {
      when(() => repo.getOrderAmountShown()).thenAnswer((_) async => OrderAmountShown.profit);
      return OrderAmountCubit(repo);
    },
    act: (c) => c.load(),
    expect: () => [OrderAmountShown.profit],
  );

  blocTest<OrderAmountCubit, OrderAmountShown>(
    'set emits and persists',
    build: () => OrderAmountCubit(repo),
    act: (c) => c.set(OrderAmountShown.profit),
    expect: () => [OrderAmountShown.profit],
    verify: (_) => verify(() => repo.setOrderAmountShown(OrderAmountShown.profit)).called(1),
  );

  blocTest<OrderAmountCubit, OrderAmountShown>(
    'a failed write still applies the choice for this session',
    build: () {
      when(() => repo.setOrderAmountShown(any()))
          .thenAnswer((_) async => const Error(DatabaseFailure('disk full')));
      return OrderAmountCubit(repo);
    },
    act: (c) => c.set(OrderAmountShown.profit),
    expect: () => [OrderAmountShown.profit],
  );
}
