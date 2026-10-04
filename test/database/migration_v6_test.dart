import 'dart:io';

import 'package:craftbook/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../support/legacy_schema.dart';
import '../support/sqlite.dart';

/// The v6 step: the social shortcuts table.
void main() {
  setUpAll(useHostSqlite);

  late Directory dir;
  late File file;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migration_v6_');
    file = File('${dir.path}/craftbook.sqlite');
  });
  tearDown(() => dir.delete(recursive: true));

  /// A schema 5 database holding one order.
  Future<void> v5WithAnOrder() async {
    final db = AppDatabase.file(file);
    await db.customSelect('SELECT 1').get(); // creates the current schema
    await db.close();
    final raw5 = raw.sqlite3.open(file.path);
    try {
      downgradeToV5(raw5);
      raw5.execute(
        'INSERT INTO orders (customer_name, order_date, ship_by_date, status, total_sales) '
        "VALUES ('Ana', 0, 0, 'pending', 450)",
      );
    } finally {
      raw5.dispose();
    }
  }

  test('adds an empty social_links table and keeps existing data', () async {
    await v5WithAnOrder();
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    expect(await db.select(db.socialLinks).get(), isEmpty);
    expect(await db.select(db.orders).get(), hasLength(1));
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 6);
  });

  test('the migrated table takes links like a fresh one', () async {
    await v5WithAnOrder();
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    final id = await db.into(db.socialLinks).insert(
          SocialLinksCompanion.insert(
            platform: 'shopee',
            label: 'Shopee',
            url: 'https://shopee.ph/shop',
          ),
        );
    final link = await (db.select(db.socialLinks)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    expect(link.position, 0);
    expect(link.colorValue, isNull);
    expect(link.url, 'https://shopee.ph/shop');
  });
}
