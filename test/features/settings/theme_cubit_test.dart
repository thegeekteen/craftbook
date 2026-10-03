import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/settings/domain/repositories/settings_repository.dart';
import 'package:craftbook/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late _MockSettings repo;

  setUpAll(() => registerFallbackValue(ThemeMode.system));

  setUp(() {
    repo = _MockSettings();
    when(() => repo.setThemeMode(any())).thenAnswer((_) async => const Success(null));
  });

  test('starts on Auto', () {
    expect(ThemeCubit(repo).state, ThemeMode.system);
  });

  blocTest<ThemeCubit, ThemeMode>(
    'load emits the stored mode',
    build: () {
      when(() => repo.getThemeMode()).thenAnswer((_) async => ThemeMode.dark);
      return ThemeCubit(repo);
    },
    act: (c) => c.load(),
    expect: () => [ThemeMode.dark],
  );

  blocTest<ThemeCubit, ThemeMode>(
    'setMode emits and persists',
    build: () => ThemeCubit(repo),
    act: (c) => c.setMode(ThemeMode.light),
    expect: () => [ThemeMode.light],
    verify: (_) => verify(() => repo.setThemeMode(ThemeMode.light)).called(1),
  );
}
