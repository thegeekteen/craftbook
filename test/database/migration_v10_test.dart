import 'dart:io';

import 'package:craftbook/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../support/legacy_schema.dart';

/// The v10 step: a BOM line can make several products from its pieces.
void main() {
  late Directory dir;
  late File file;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migration_v10_');
    file = File('${dir.path}/craftbook.sqlite');
  });
  tearDown(() => dir.delete(recursive: true));

  test('existing BOM lines make one product each', () async {
    final db = AppDatabase.file(file);
    await db.customSelect('SELECT 1').get(); // creates the current schema
    await db.close();
    final raw9 = raw.sqlite3.open(file.path);
    try {
      downgradeToV9(raw9);
      raw9.execute(
          "INSERT INTO materials (name, pack_size, pack_price, unit_cost, "
          "alert_level) VALUES ('Yarn', 10, 100, 10, 2)");
      raw9.execute("INSERT INTO products (name, sell_price) VALUES "
          "('Tulip', 450)");
      raw9.execute('INSERT INTO bom_items (product_id, material_id, '
          'quantity_required) VALUES (1, 1, 3)');
    } finally {
      raw9.close();
    }

    final upgraded = AppDatabase.file(file);
    addTearDown(upgraded.close);
    final bom = await upgraded.select(upgraded.bomItems).getSingle();
    expect((bom.quantityRequired, bom.makes), (3, 1));
    expect(
        (await upgraded.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        AppDatabase.currentSchemaVersion);
  });
}
