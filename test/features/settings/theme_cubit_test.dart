import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/theme/palettes.dart';
import 'package:craftbook/features/settings/domain/entities/theme_settings.dart';
import 'package:craftbook/features/settings/domain/repositories/settings_repository.dart';
import 'package:craftbook/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late _MockSettings repo;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(AppPalette.forest);
  });

  setUp(() {
    repo = _MockSettings();
    when(() => repo.setThemeMode(any())).thenAnswer((_) async => const Success(null));
    when(() => repo.setPalette(any())).thenAnswer((_) async => const Success(null));
  });

  test('starts on Auto with the Forest scheme', () {
    expect(ThemeCubit(repo).state, const ThemeSettings());
  });

  blocTest<ThemeCubit, ThemeSettings>(
    'load emits the stored mode and palette',
    build: () {
      when(() => repo.getThemeMode()).thenAnswer((_) async => ThemeMode.dark);
      when(() => repo.getPalette()).thenAnswer((_) async => AppPalette.ocean);
      return ThemeCubit(repo);
    },
    act: (c) => c.load(),
    expect: () => [const ThemeSettings(mode: ThemeMode.dark, palette: AppPalette.ocean)],
  );

  blocTest<ThemeCubit, ThemeSettings>(
    'setMode emits and persists, keeping the palette',
    build: () => ThemeCubit(repo),
    seed: () => const ThemeSettings(palette: AppPalette.berry),
    act: (c) => c.setMode(ThemeMode.light),
    expect: () => [const ThemeSettings(mode: ThemeMode.light, palette: AppPalette.berry)],
    verify: (_) => verify(() => repo.setThemeMode(ThemeMode.light)).called(1),
  );

  blocTest<ThemeCubit, ThemeSettings>(
    'setPalette emits and persists, keeping the mode',
    build: () => ThemeCubit(repo),
    seed: () => const ThemeSettings(mode: ThemeMode.dark),
    act: (c) => c.setPalette(AppPalette.sunset),
    expect: () => [const ThemeSettings(mode: ThemeMode.dark, palette: AppPalette.sunset)],
    verify: (_) => verify(() => repo.setPalette(AppPalette.sunset)).called(1),
  );
}
