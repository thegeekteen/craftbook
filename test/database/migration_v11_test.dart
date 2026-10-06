import 'dart:io';

import 'package:craftbook/core/constants/app_constants.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/database/seed_units.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../support/legacy_schema.dart';

/// The v11 step: units of measure, with everything already in the database
/// counted in "pc" — the unit the screens showed before units existed.
void main() {
  late Directory dir;
  late File file;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migration_v11_');
    file = File('${dir.path}/craftbook.sqlite');
  });
  tearDown(() => dir.delete(recursive: true));

  /// A v10 database holding one material and one product.
  Future<void> v10WithItems() async {
    final db = AppDatabase.file(file);
    await db.customSelect('SELECT 1').get(); // creates the current schema
    await db.close();
    final raw10 = raw.sqlite3.open(file.path);
    try {
      downgradeToV10(raw10);
      raw10.execute(
          "INSERT INTO materials (name, pack_size, pack_price, unit_cost, "
          "quantity_on_hand, alert_level) "
          "VALUES ('Illustration board', 1, 40, 40, 5, 2)");
      raw10.execute("INSERT INTO products (name, sell_price) "
          "VALUES ('Bubble head', 120)");
    } finally {
      raw10.close();
    }
  }

  test('existing items are counted in the seeded default unit', () async {
    await v10WithItems();

    final upgraded = AppDatabase.file(file);
    addTearDown(upgraded.close);

    final units = await upgraded.select(upgraded.units).get();
    expect(units.map((u) => u.label), seedUnitLabels);
    expect(units.where((u) => u.isDefault).length, 1);

    final pc = units.firstWhere((u) => u.isDefault);
    // The literal defaults baked into materials.unit_id and products.unit_id
    // have to keep pointing at the seeded "pc", or a fresh install and an
    // upgraded one would disagree about what an unset unit means.
    expect((AppConstants.defaultUnitId, AppConstants.defaultUnitLabel),
        (pc.id, pc.label));

    final material = await upgraded.select(upgraded.materials).getSingle();
    final product = await upgraded.select(upgraded.products).getSingle();
    expect(material.unitId, pc.id);
    expect(product.unitId, pc.id);

    // The table rebuild kept the rest of each row.
    expect(
      (
        material.name,
        material.packSize,
        material.packPrice,
        material.unitCost,
        material.quantityOnHand,
        material.alertLevel
      ),
      ('Illustration board', 1, 40.0, 40.0, 5, 2),
    );
    expect((product.name, product.sellPrice), ('Bubble head', 120.0));
    expect(
      (await upgraded.customSelect('PRAGMA user_version').getSingle())
          .data
          .values
          .single,
      AppDatabase.currentSchemaVersion,
    );
  });

  /// The v11 step rebuilds materials and products through Drift rather than
  /// ALTER TABLE, so an upgraded database and a fresh one should be identical
  /// column for column — including the DEFAULT clause ALTER TABLE would leave.
  test('an upgraded database has the same schema as a fresh one', () async {
    const tables = ['units', 'materials', 'products'];
    await v10WithItems();

    // One database at a time: two live AppDatabase instances would warn about
    // sharing an executor, and the comparison doesn't need both open.
    final upgraded = AppDatabase.file(file);
    await upgraded.customSelect('SELECT 1').get();
    final migrated = {for (final t in tables) t: await _columns(upgraded, t)};
    await upgraded.close();

    final fresh = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(fresh.close);
    await fresh.customSelect('SELECT 1').get();

    for (final table in tables) {
      expect(
        await _columns(fresh, table),
        migrated[table],
        reason: '"$table" differs between an upgraded and a fresh database',
      );
    }
  });
}

/// (name, type, notnull, default) per column, in order.
Future<List<List<Object?>>> _columns(AppDatabase db, String table) async {
  final rows = await db.customSelect('PRAGMA table_info("$table")').get();
  return [
    for (final r in rows)
      [r.data['name'], r.data['type'], r.data['notnull'], r.data['dflt_value']]
  ];
}
