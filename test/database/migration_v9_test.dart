import 'dart:io';

import 'package:craftbook/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../support/legacy_schema.dart';

/// The v9 step: discounts, tax and paid status on orders, discount presets
/// and the channel's paid default.
void main() {
  late Directory dir;
  late File file;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migration_v9_');
    file = File('${dir.path}/craftbook.sqlite');
  });
  tearDown(() => dir.delete(recursive: true));

  /// A schema 8 database with a channel, one shipped and one pending order.
  Future<void> v8WithOrders() async {
    final db = AppDatabase.file(file);
    await db.customSelect('SELECT 1').get(); // creates the current schema
    await db.close();
    final raw8 = raw.sqlite3.open(file.path);
    try {
      downgradeToV8(raw8);
      raw8.execute("INSERT INTO channels (name) VALUES ('Shopee')");
      raw8.execute(
        'INSERT INTO orders (customer_name, order_date, ship_by_date, '
        'shipped_at, status, channel_id, total_sales, total_material_cost, '
        'channel_fees, shipping_cost, profit) VALUES '
        "('Ana', 100, 200, 300, 'shipped', 1, 1000, 300, 100, 40, 560), "
        "('Ben', 150, 250, NULL, 'pending', 1, 500, 100, 50, 40, 310)",
      );
    } finally {
      raw8.close();
    }
  }

  test('existing orders are paid, with no discount or tax', () async {
    await v8WithOrders();
    final db = AppDatabase.file(file);
    addTearDown(db.close);

    final orders = await db.select(db.orders).get();
    expect(orders.map((o) => o.isPaid), [true, true]);
    expect(orders.map((o) => o.discountTotal), [0, 0]);
    expect(orders.map((o) => o.taxRate), [null, null]);
    expect(orders.map((o) => o.taxAmount), [0, 0]);
    // Paid when it shipped, or when it was placed if it hasn't.
    expect(orders[0].paidAt, orders[0].shippedAt);
    expect(orders[1].paidAt, orders[1].orderDate);
    expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        AppDatabase.currentSchemaVersion);
  });

  test('existing channels take payment up front', () async {
    await v8WithOrders();
    final db = AppDatabase.file(file);
    addTearDown(db.close);
    expect((await db.select(db.channels).getSingle()).paidByDefault, isTrue);
  });

  test('the new tables exist and start empty', () async {
    await v8WithOrders();
    final db = AppDatabase.file(file);
    addTearDown(db.close);
    expect(await db.select(db.orderDiscounts).get(), isEmpty);
    expect(await db.select(db.discountPresets).get(), isEmpty);
  });
}
