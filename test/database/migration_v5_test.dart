import 'dart:io';

import 'package:craftbook/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../support/legacy_schema.dart';
import '../support/sqlite.dart';

/// The v5 step: the notebook table.
void main() {
  setUpAll(useHostSqlite);

  late Directory dir;
  late File file;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migration_v5_');
    file = File('${dir.path}/craftbook.sqlite');
  });
  tearDown(() => dir.delete(recursive: true));

  /// A schema 4 database holding one order.
  Future<void> v4WithAnOrder() async {
    final db = AppDatabase.file(file);
    await db.customSelect('SELECT 1').get(); // creates the current schema
    await db.close();
    final raw4 = raw.sqlite3.open(file.path);
    try {
      downgradeToV4(raw4);
      raw4.execute(
        'INSERT INTO orders (customer_name, order_date, ship_by_date, status, total_sales) '
        "VALUES ('Ana', 0, 0, 'pending', 450)",
      );
    } finally {
      raw4.dispose();
    }
  }

  test('adds an empty notes table and keeps existing data', () async {
    await v4WithAnOrder();
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    expect(await db.select(db.notes).get(), isEmpty);
    expect(await db.select(db.orders).get(), hasLength(1));
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 5);
  });

  test('the migrated table takes notes like a fresh one', () async {
    await v4WithAnOrder();
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    final id = await db.into(db.notes).insert(
          const NotesCompanion(body: Value('[{"insert":"Hi\\n"}]')),
        );
    final note = await (db.select(db.notes)..where((t) => t.id.equals(id))).getSingle();
    expect(note.title, '');
    expect(note.isPinned, isFalse);
    expect(note.body, '[{"insert":"Hi\\n"}]');
    expect(note.updatedAt.difference(DateTime.now()).inMinutes.abs(), lessThan(1));
  });
}
