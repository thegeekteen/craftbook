import 'package:sqlite3/sqlite3.dart' as raw;

/// Rebuilds [table] with the INTEGER quantity columns schema v11 declared,
/// copying every row across. Test-only stand-in for the old DDL, so the v12
/// migration has something real to convert.
void _rebuildAsV11(
  raw.Database db,
  String table,
  String columnDefs,
  List<String> columns,
) {
  final copy = columns.join(', ');
  db.execute('ALTER TABLE $table RENAME TO ${table}_v12');
  db.execute('CREATE TABLE $table ($columnDefs)');
  db.execute('INSERT INTO $table ($copy) SELECT $copy FROM ${table}_v12');
  db.execute('DROP TABLE ${table}_v12');
}

const _timestamps = '"created_at" INTEGER NOT NULL DEFAULT '
    "(CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))";

/// Turns a current database back into schema 11, from before quantities could
/// be fractional.
void downgradeToV11(raw.Database db) {
  _rebuildAsV11(
    db,
    'materials',
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"name" TEXT NOT NULL, '
        '"unit_id" INTEGER NOT NULL DEFAULT 1, '
        '"pack_size" INTEGER NOT NULL, '
        '"pack_price" REAL NOT NULL, '
        '"unit_cost" REAL NOT NULL, '
        '"quantity_on_hand" INTEGER NOT NULL DEFAULT 0, '
        '"quantity_promised" INTEGER NOT NULL DEFAULT 0, '
        '"alert_level" INTEGER NOT NULL, '
        '"supplier" TEXT, '
        '"last_received_at" INTEGER, '
        '"is_archived" INTEGER NOT NULL DEFAULT 0 '
        'CHECK ("is_archived" IN (0, 1)), '
        '$_timestamps, '
        '"updated_at" INTEGER NOT NULL DEFAULT '
        "(CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))",
    [
      'id',
      'name',
      'unit_id',
      'pack_size',
      'pack_price',
      'unit_cost',
      'quantity_on_hand',
      'quantity_promised',
      'alert_level',
      'supplier',
      'last_received_at',
      'is_archived',
      'created_at',
      'updated_at'
    ],
  );
  _rebuildAsV11(
    db,
    'products',
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"name" TEXT NOT NULL, '
        '"description" TEXT, '
        '"sell_price" REAL NOT NULL, '
        '"unit_id" INTEGER NOT NULL DEFAULT 1, '
        '"is_archived" INTEGER NOT NULL DEFAULT 0 '
        'CHECK ("is_archived" IN (0, 1)), '
        '"is_standalone" INTEGER NOT NULL DEFAULT 0 '
        'CHECK ("is_standalone" IN (0, 1)), '
        '"quantity_on_hand" INTEGER NOT NULL DEFAULT 0, '
        '"quantity_promised" INTEGER NOT NULL DEFAULT 0, '
        '"unit_cost" REAL NOT NULL DEFAULT 0.0, '
        '"alert_level" INTEGER NOT NULL DEFAULT 0, '
        '"photo" BLOB, '
        '$_timestamps, '
        '"updated_at" INTEGER NOT NULL DEFAULT '
        "(CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))",
    [
      'id',
      'name',
      'description',
      'sell_price',
      'unit_id',
      'is_archived',
      'is_standalone',
      'quantity_on_hand',
      'quantity_promised',
      'unit_cost',
      'alert_level',
      'photo',
      'created_at',
      'updated_at'
    ],
  );
  _rebuildAsV11(
    db,
    'bom_items',
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"product_id" INTEGER NOT NULL, '
        '"material_id" INTEGER NOT NULL, '
        '"quantity_required" INTEGER NOT NULL, '
        '"makes" INTEGER NOT NULL DEFAULT 1, '
        '$_timestamps',
    [
      'id',
      'product_id',
      'material_id',
      'quantity_required',
      'makes',
      'created_at'
    ],
  );
  _rebuildAsV11(
    db,
    'order_materials',
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"order_id" INTEGER NOT NULL, '
        '"material_id" INTEGER NOT NULL, '
        '"planned_quantity" INTEGER NOT NULL, '
        '"actual_quantity" INTEGER NOT NULL, '
        '"waste_quantity" INTEGER NOT NULL DEFAULT 0, '
        '"waste_reason" TEXT, '
        '"unit_cost" REAL NOT NULL, '
        '$_timestamps',
    [
      'id',
      'order_id',
      'material_id',
      'planned_quantity',
      'actual_quantity',
      'waste_quantity',
      'waste_reason',
      'unit_cost',
      'created_at'
    ],
  );
  _rebuildAsV11(
    db,
    'order_items',
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"order_id" INTEGER NOT NULL, '
        '"product_id" INTEGER NOT NULL, '
        '"quantity" INTEGER NOT NULL, '
        '"unit_price" REAL NOT NULL, '
        '"subtotal" REAL NOT NULL, '
        '$_timestamps',
    [
      'id',
      'order_id',
      'product_id',
      'quantity',
      'unit_price',
      'subtotal',
      'created_at'
    ],
  );
  _rebuildAsV11(
    db,
    'order_products',
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"order_id" INTEGER NOT NULL, '
        '"product_id" INTEGER NOT NULL, '
        '"quantity" INTEGER NOT NULL, '
        '"unit_cost" REAL NOT NULL, '
        '$_timestamps',
    ['id', 'order_id', 'product_id', 'quantity', 'unit_cost', 'created_at'],
  );
  _rebuildAsV11(
    db,
    'stock_movements',
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"material_id" INTEGER NOT NULL, '
        '"order_id" INTEGER, '
        '"type" TEXT NOT NULL, '
        '"quantity" INTEGER NOT NULL, '
        '"unit_cost" REAL NOT NULL, '
        '$_timestamps, '
        '"reference" TEXT',
    [
      'id',
      'material_id',
      'order_id',
      'type',
      'quantity',
      'unit_cost',
      'created_at',
      'reference'
    ],
  );
  _rebuildAsV11(
    db,
    'product_stock_movements',
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"product_id" INTEGER NOT NULL, '
        '"order_id" INTEGER, '
        '"type" TEXT NOT NULL, '
        '"quantity" INTEGER NOT NULL, '
        '"unit_cost" REAL NOT NULL, '
        '$_timestamps, '
        '"reference" TEXT',
    [
      'id',
      'product_id',
      'order_id',
      'type',
      'quantity',
      'unit_cost',
      'created_at',
      'reference'
    ],
  );
  db.execute('PRAGMA user_version = 11');
}

/// Turns a current database back into schema 10, from before units of measure.
void downgradeToV10(raw.Database db) {
  downgradeToV11(db);
  db.execute('DROP TABLE units');
  db.execute('ALTER TABLE materials DROP COLUMN unit_id');
  db.execute('ALTER TABLE products DROP COLUMN unit_id');
  db.execute('PRAGMA user_version = 10');
}

/// Turns a current database back into schema 9, from before a BOM line could
/// make several products.
void downgradeToV9(raw.Database db) {
  downgradeToV10(db);
  db.execute('ALTER TABLE bom_items DROP COLUMN makes');
  db.execute('PRAGMA user_version = 9');
}

/// Turns a current database back into schema 8, from before discounts, tax
/// and paid status.
void downgradeToV8(raw.Database db) {
  downgradeToV9(db);
  db.execute('DROP TABLE order_discounts');
  db.execute('DROP TABLE discount_presets');
  for (final column in [
    'discount_total',
    'tax_rate',
    'tax_amount',
    'tax_inclusive',
    'is_paid',
    'paid_at',
  ]) {
    db.execute('ALTER TABLE orders DROP COLUMN $column');
  }
  db.execute('ALTER TABLE channels DROP COLUMN paid_by_default');
  db.execute('PRAGMA user_version = 8');
}

/// Turns a current database back into schema 7, from before archiving:
/// products get their "show in new orders" switch back, all on.
void downgradeToV7(raw.Database db) {
  downgradeToV8(db);
  db.execute('ALTER TABLE products DROP COLUMN is_archived');
  db.execute('ALTER TABLE materials DROP COLUMN is_archived');
  db.execute('ALTER TABLE products ADD COLUMN "is_active" INTEGER NOT NULL '
      'DEFAULT 1 CHECK ("is_active" IN (0, 1))');
  db.execute('PRAGMA user_version = 7');
}

/// Turns a current database back into schema 6, from before product photos.
void downgradeToV6(raw.Database db) {
  downgradeToV7(db);
  db.execute('ALTER TABLE products DROP COLUMN photo');
  db.execute('PRAGMA user_version = 6');
}

/// Turns a current database back into schema 5, from before social shortcuts.
void downgradeToV5(raw.Database db) {
  downgradeToV6(db);
  db.execute('DROP TABLE social_links');
  db.execute('PRAGMA user_version = 5');
}

/// Turns a current database back into schema 4, from before the notebook.
void downgradeToV4(raw.Database db) {
  downgradeToV5(db);
  db.execute('DROP TABLE notes');
  db.execute('PRAGMA user_version = 4');
}

/// Turns a current database back into schema 3, from before order fields:
/// orders get their built-in address column back. Fixtures for older
/// schemas start here, so the v4 step has something to upgrade.
void downgradeToV3(raw.Database db) {
  downgradeToV4(db);
  db.execute('DROP TABLE order_field_values');
  db.execute('DROP TABLE order_field_definitions');
  db.execute(
      "ALTER TABLE orders ADD COLUMN customer_address TEXT NOT NULL DEFAULT ''");
  db.execute('PRAGMA user_version = 3');
}
