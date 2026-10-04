import 'dart:io';

import 'package:craftbook/database/app_database.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../support/legacy_schema.dart';

/// The v8 step: archiving replaces the product's "show in new orders"
/// switch, and materials can be archived too.
void main() {
  late Directory dir;
  late File file;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migration_v8_');
    file = File('${dir.path}/craftbook.sqlite');
  });
  tearDown(() => dir.delete(recursive: true));

  /// A schema 7 database with one shown and one hidden product, and a
  /// material.
  Future<void> v7WithProducts() async {
    final db = AppDatabase.file(file);
    await db.customSelect('SELECT 1').get(); // creates the current schema
    await db.close();
    final raw7 = raw.sqlite3.open(file.path);
    try {
      downgradeToV7(raw7);
      raw7.execute(
        'INSERT INTO products (name, sell_price, is_active) VALUES '
        "('Tulip', 450, 1), ('Rose', 300, 0)",
      );
      raw7.execute(
        'INSERT INTO materials (name, pack_size, pack_price, unit_cost, '
        "alert_level) VALUES ('Yarn', 10, 100, 10, 5)",
      );
    } finally {
      raw7.close();
    }
  }

  Future<List<Map<String, Object?>>> rows(AppDatabase db, String sql) async =>
      [for (final r in await db.customSelect(sql).get()) r.data];

  test('a hidden product comes back archived', () async {
    await v7WithProducts();
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    final products = await (db.select(db.products)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    expect(products.map((p) => (p.name, p.sellPrice, p.isArchived)), [
      ('Tulip', 450.0, false),
      ('Rose', 300.0, true),
    ]);

    final columns = await rows(db, 'PRAGMA table_info(products)');
    expect(columns.map((c) => c['name']), isNot(contains('is_active')));
    expect((await rows(db, 'PRAGMA user_version')).single.values.single,
        AppDatabase.currentSchemaVersion);
  });

  test('existing materials start unarchived', () async {
    await v7WithProducts();
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    final material = await db.select(db.materials).getSingle();
    expect(material.name, 'Yarn');
    expect(material.isArchived, isFalse);
  });
}
