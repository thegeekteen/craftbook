import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/utils/currency_formatter.dart';
import 'package:craftbook/core/utils/currency_setting.dart';
import 'package:craftbook/features/settings/domain/repositories/settings_repository.dart';
import 'package:craftbook/features/settings/presentation/bloc/currency_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late _MockSettings repo;
  final usd = CurrencySetting.preset('USD')!;

  setUpAll(() => registerFallbackValue(CurrencySetting.php));

  setUp(() {
    repo = _MockSettings();
    when(() => repo.setCurrency(any()))
        .thenAnswer((_) async => const Success(null));
  });
  tearDown(() => CurrencyFormatter.configure(CurrencySetting.php));

  test('starts on pesos', () {
    expect(CurrencyCubit(repo).state, CurrencySetting.php);
  });

  blocTest<CurrencyCubit, CurrencySetting>(
    'load emits the stored currency and reconfigures the formatter',
    build: () {
      when(() => repo.getCurrency()).thenAnswer((_) async => usd);
      return CurrencyCubit(repo);
    },
    act: (c) => c.load(),
    expect: () => [usd],
    verify: (_) => expect(CurrencyFormatter.symbol, r'$'),
  );

  blocTest<CurrencyCubit, CurrencySetting>(
    'set emits, persists and reconfigures the formatter',
    build: () => CurrencyCubit(repo),
    act: (c) => c.set(usd),
    expect: () => [usd],
    verify: (_) {
      verify(() => repo.setCurrency(usd)).called(1);
      expect(CurrencyFormatter.format(5), r'$5.00');
    },
  );
}
