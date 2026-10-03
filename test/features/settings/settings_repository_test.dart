import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/theme/palettes.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/sqlite.dart';

void main() {
  useHostSqlite();
  late AppDatabase db;
  late SettingsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SettingsRepositoryImpl(db);
  });
  tearDown(() => db.close());

  test('defaults to Auto when nothing is stored', () async {
    expect(await repo.getThemeMode(), ThemeMode.system);
  });

  for (final mode in ThemeMode.values) {
    test('round-trips ${mode.name}', () async {
      expect(await repo.setThemeMode(mode), isA<Success<void>>());
      expect(await repo.getThemeMode(), mode);
    });
  }

  test('overwriting keeps a single row', () async {
    await repo.setThemeMode(ThemeMode.dark);
    await repo.setThemeMode(ThemeMode.light);
    expect(await db.select(db.settings).get(), hasLength(1));
    expect(await repo.getThemeMode(), ThemeMode.light);
  });

  test('an unknown stored value falls back to Auto', () async {
    await db.into(db.settings).insert(
          SettingsCompanion.insert(key: SettingsRepositoryImpl.themeModeKey, value: 'sepia'),
        );
    expect(await repo.getThemeMode(), ThemeMode.system);
  });

  test('palette defaults to Forest', () async {
    expect(await repo.getPalette(), AppPalette.forest);
  });

  for (final palette in AppPalette.values) {
    test('round-trips palette ${palette.name}', () async {
      expect(await repo.setPalette(palette), isA<Success<void>>());
      expect(await repo.getPalette(), palette);
    });
  }

  test('an unknown stored palette falls back to Forest', () async {
    await db.into(db.settings).insert(
          SettingsCompanion.insert(key: SettingsRepositoryImpl.paletteKey, value: 'neon'),
        );
    expect(await repo.getPalette(), AppPalette.forest);
  });

  test('mode and palette are stored independently', () async {
    await repo.setThemeMode(ThemeMode.dark);
    await repo.setPalette(AppPalette.berry);
    await repo.setPalette(AppPalette.ocean);
    expect(await db.select(db.settings).get(), hasLength(2));
    expect(await repo.getThemeMode(), ThemeMode.dark);
    expect(await repo.getPalette(), AppPalette.ocean);
  });
}
