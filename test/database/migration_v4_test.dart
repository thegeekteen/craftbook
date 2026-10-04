import 'dart:io';

import 'package:craftbook/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../support/legacy_schema.dart';
import '../support/sqlite.dart';

/// The v4 step: the built-in address becomes an "Address" order field.
void main() {
  setUpAll(useHostSqlite);

  late Directory dir;
  late File file;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migration_v4_');
    file = File('${dir.path}/craftbook.sqlite');
  });
  tearDown(() => dir.delete(recursive: true));

  /// A schema 3 database whose orders have these addresses.
  Future<void> v3WithAddresses(List<String> addresses) async {
    final db = AppDatabase.file(file);
    await db.customSelect('SELECT 1').get(); // creates the current schema
    await db.close();
    final raw3 = raw.sqlite3.open(file.path);
    try {
      downgradeToV3(raw3);
      for (final (i, address) in addresses.indexed) {
        raw3.execute(
          'INSERT INTO orders (customer_name, customer_address, order_date, ship_by_date, status, total_sales) '
          "VALUES ('Ana $i', ?, 0, 0, 'pending', 450)",
          [address],
        );
      }
    } finally {
      raw3.dispose();
    }
  }

  Future<List<Map<String, Object?>>> rows(AppDatabase db, String sql) async =>
      [for (final r in await db.customSelect(sql).get()) r.data];

  test('moves non-empty addresses into an Address field', () async {
    await v3WithAddresses(['  22 Rizal Ave  ', '', '   ', '9 Kalayaan St']);
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    final fields = await rows(db, 'SELECT * FROM order_field_definitions');
    expect(fields, hasLength(1));
    expect(fields.single['name'], 'Address');
    expect(fields.single['type'], 'text');
    expect(fields.single['is_multiline'], 1);
    expect(fields.single['position'], 0);
    expect(fields.single['is_archived'], 0);

    final values = await rows(db, 'SELECT order_id, value FROM order_field_values ORDER BY order_id');
    expect(values, [
      {'order_id': 1, 'value': '22 Rizal Ave'},
      {'order_id': 4, 'value': '9 Kalayaan St'},
    ]);

    final columns = await rows(db, 'PRAGMA table_info(orders)');
    expect(columns.map((c) => c['name']), isNot(contains('customer_address')));
    expect((await rows(db, 'PRAGMA user_version')).single.values.single, AppDatabase.currentSchemaVersion);
  });

  test('adds no field when no order has an address', () async {
    await v3WithAddresses(['', '  ']);
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    expect(await rows(db, 'SELECT * FROM order_field_definitions'), isEmpty);
    expect(await rows(db, 'SELECT * FROM order_field_values'), isEmpty);
    final columns = await rows(db, 'PRAGMA table_info(orders)');
    expect(columns.map((c) => c['name']), isNot(contains('customer_address')));
  });

  test('a fresh install starts with no fields', () async {
    final db = AppDatabase.file(file);
    addTearDown(db.close);
    expect(await rows(db, 'SELECT * FROM order_field_definitions'), isEmpty);
  });

  test('deleting an order deletes its values', () async {
    await v3WithAddresses(['22 Rizal Ave']);
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    await db.customStatement('DELETE FROM orders');
    expect(await rows(db, 'SELECT * FROM order_field_values'), isEmpty);
  });

  test('a field orders still use cannot be deleted', () async {
    await v3WithAddresses(['22 Rizal Ave']);
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    expect(
      () => db.customStatement('DELETE FROM order_field_definitions'),
      throwsA(anything),
    );
  });
}
