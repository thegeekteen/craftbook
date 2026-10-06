import 'dart:io';

import 'package:craftbook/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../support/legacy_schema.dart';

/// The v12 step: quantities become fractional, so a shop that counts in
/// boards or metres isn't forced into whole pieces.
void main() {
  late Directory dir;
  late File file;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migration_v12_');
    file = File('${dir.path}/craftbook.sqlite');
  });
  tearDown(() => dir.delete(recursive: true));

  /// A v11 database with a material, a product, a BOM line and an order line,
  /// all counted in whole pieces.
  Future<void> v11WithRows() async {
    final db = AppDatabase.file(file);
    await db.customSelect('SELECT 1').get(); // creates the current schema
    await db.close();
    final raw11 = raw.sqlite3.open(file.path);
    try {
      downgradeToV11(raw11);
      raw11.execute("INSERT INTO materials (id, name, unit_id, pack_size, "
          'pack_price, unit_cost, quantity_on_hand, quantity_promised, '
          "alert_level) VALUES (1, 'Board', 1, 1, 40, 40, 5, 2, 3)");
      raw11.execute("INSERT INTO products (id, name, sell_price, unit_id) "
          "VALUES (1, 'Bubble head', 120, 1)");
      raw11.execute('INSERT INTO bom_items (product_id, material_id, '
          'quantity_required, makes) VALUES (1, 1, 1, 1)');
      raw11.execute('INSERT INTO orders (id, customer_name, status, '
          'order_date, ship_by_date, channel_id, total_sales, '
          'total_material_cost, channel_fees, shipping_cost, profit) '
          "VALUES (1, 'Maria', 'pending', 0, 0, 1, 120, 40, 0, 0, 80)");
      raw11.execute('INSERT INTO order_items (order_id, product_id, quantity, '
          'unit_price, subtotal) VALUES (1, 1, 3, 120, 360)');
      raw11.execute('INSERT INTO order_materials (order_id, material_id, '
          'planned_quantity, actual_quantity, unit_cost) '
          'VALUES (1, 1, 3, 3, 40)');
      raw11.execute('INSERT INTO stock_movements (material_id, type, '
          "quantity, unit_cost) VALUES (1, 'received', 5, 40)");
    } finally {
      raw11.close();
    }
  }

  test('whole counts survive the conversion to fractional quantities',
      () async {
    await v11WithRows();

    final upgraded = AppDatabase.file(file);
    addTearDown(upgraded.close);

    final material = await upgraded.select(upgraded.materials).getSingle();
    expect(
      (
        material.quantityOnHand,
        material.quantityPromised,
        material.alertLevel,
        material.packSize
      ),
      (5.0, 2.0, 3.0, 1.0),
    );
    final product = await upgraded.select(upgraded.products).getSingle();
    expect((product.quantityOnHand, product.quantityPromised), (0.0, 0.0));
    final bom = await upgraded.select(upgraded.bomItems).getSingle();
    expect((bom.quantityRequired, bom.makes), (1.0, 1.0));
    final item = await upgraded.select(upgraded.orderItems).getSingle();
    expect(item.quantity, 3.0);
    final orderMaterial =
        await upgraded.select(upgraded.orderMaterials).getSingle();
    expect(
      (
        orderMaterial.plannedQuantity,
        orderMaterial.actualQuantity,
        orderMaterial.wasteQuantity
      ),
      (3.0, 3.0, 0.0),
    );
    final movement = await upgraded.select(upgraded.stockMovements).getSingle();
    expect(movement.quantity, 5.0);
    expect(
      (await upgraded.customSelect('PRAGMA user_version').getSingle())
          .data
          .values
          .single,
      AppDatabase.currentSchemaVersion,
    );

    // And the converted columns accept fractions from here on.
    await (upgraded.update(upgraded.materials))
        .write(MaterialsCompanion(quantityOnHand: const Value(4.25)));
    expect(
        (await upgraded.select(upgraded.materials).getSingle()).quantityOnHand,
        4.25);
  });

  /// The step rebuilds every quantity table through Drift, so an upgraded
  /// database and a fresh one should be identical column for column.
  test('an upgraded database has the same schema as a fresh one', () async {
    const tables = [
      'materials',
      'products',
      'bom_items',
      'order_materials',
      'order_items',
      'order_products',
      'stock_movements',
      'product_stock_movements',
    ];
    await v11WithRows();

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
