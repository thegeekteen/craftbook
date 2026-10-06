import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/utils/currency_setting.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/debug/domain/usecases/clear_shop_data.dart';
import 'package:craftbook/features/debug/domain/usecases/seed_fake_shop.dart';
import 'package:craftbook/features/settings/domain/entities/tax_settings.dart';
import 'package:craftbook/features/settings/domain/repositories/settings_repository.dart';
import 'package:craftbook/features/units/domain/repositories/unit_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

T _ok<T>(Result<T> result) => switch (result) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// A fresh in-memory database with everything registered, as on a new phone.
Future<AppDatabase> _freshDatabase() async {
  await getIt.reset();
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await configureDependencies(database: db);
  return db;
}

/// The tables in the file, as SQL sees them rather than as Drift declares them:
/// a table a future feature forgot to wipe still shows up here.
Future<List<String>> _liveTables(AppDatabase db) async {
  final rows = await db
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      )
      .get();
  return rows.map((row) => row.read<String>('name')).toList();
}

Future<int> _rowCount(AppDatabase db, String table) async {
  final row = await db
      .customSelect('SELECT COUNT(*) AS total FROM "$table"')
      .getSingle();
  return row.read<int>('total');
}

/// Units are part of the schema, not the shop, so they are the one table a wipe
/// is expected to refill.
const _keepsItsRows = {'units'};

void main() {
  group('ClearShopData', () {
    late AppDatabase db;

    setUp(() async {
      db = await _freshDatabase();
    });

    tearDown(() async {
      await db.close();
      await getIt.reset();
    });

    test('leaves no row in any table the file has', () async {
      _ok(await getIt<SeedFakeShop>()());

      final tables = await _liveTables(db);
      // The loop below is only a guard if the query really sees the shop.
      expect(
        tables,
        containsAll([
          'orders',
          'order_items',
          'order_materials',
          'materials',
          'products',
          'bom_items',
          'channels',
          'stock_movements',
          'settings',
        ]),
        reason: 'sqlite_master did not list the shop tables',
      );
      expect(await _rowCount(db, 'orders'), greaterThan(0));

      _ok(await getIt<ClearShopData>()());

      expect(await _liveTables(db), tables,
          reason: 'a wipe empties the shop, it does not drop the schema');
      for (final table in tables) {
        if (_keepsItsRows.contains(table)) continue;
        expect(await _rowCount(db, table), 0,
            reason: '$table survived the wipe — add it to wipeAll');
      }

      // A fresh install has the unit vocabulary, so a wipe leaves one too.
      expect(await _rowCount(db, 'units'), greaterThan(0));
      final defaultUnit = _ok(await getIt<UnitRepository>().getDefaultUnit());
      expect(defaultUnit?.label, 'pc');
    });

    test('settings go back to the app defaults', () async {
      final settings = getIt<SettingsRepository>();
      _ok(await settings.setCurrency(CurrencySetting.preset('USD')!));
      _ok(await settings.setThemeMode(ThemeMode.dark));
      _ok(await settings
          .setTaxSettings(const TaxSettings(enabled: true, label: 'GST')));

      _ok(await getIt<ClearShopData>()());

      expect(await settings.getCurrency(), CurrencySetting.php);
      expect(await settings.getThemeMode(), ThemeMode.system);
      expect(await settings.getTaxSettings(),
          const TaxSettings(enabled: false, label: TaxSettings.defaultLabel));
      expect(await _rowCount(db, 'settings'), 0);
    });

    test('clearing a shop that is already empty succeeds', () async {
      _ok(await getIt<ClearShopData>()());
      expect(await getIt<ClearShopData>()(), const Success<void>(null));
    });
  });
}
