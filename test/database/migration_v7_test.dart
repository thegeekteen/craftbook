import 'dart:io';

import 'package:craftbook/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../support/legacy_schema.dart';

/// The v7 step: a photo column on products.
void main() {
  late Directory dir;
  late File file;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migration_v7_');
    file = File('${dir.path}/craftbook.sqlite');
  });
  tearDown(() => dir.delete(recursive: true));

  /// A schema 6 database holding one product.
  Future<void> v6WithAProduct() async {
    final db = AppDatabase.file(file);
    await db.customSelect('SELECT 1').get(); // creates the current schema
    await db.close();
    final raw6 = raw.sqlite3.open(file.path);
    try {
      downgradeToV6(raw6);
      raw6.execute(
        "INSERT INTO products (name, sell_price) VALUES ('Tulip', 450)",
      );
    } finally {
      raw6.close();
    }
  }

  test('adds an empty photo column and keeps existing products', () async {
    await v6WithAProduct();
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    final products = await db.select(db.products).get();
    expect(products, hasLength(1));
    expect(products.single.name, 'Tulip');
    expect(products.single.sellPrice, 450);
    expect(products.single.photo, isNull);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, AppDatabase.currentSchemaVersion);
  });

  test('the migrated column stores photo bytes', () async {
    await v6WithAProduct();
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 1, 2, 3]);
    await (db.update(db.products)..where((t) => t.name.equals('Tulip')))
        .write(ProductsCompanion(photo: Value(bytes)));
    final row = await db.select(db.products).getSingle();
    expect(row.photo, bytes);
  });
}
