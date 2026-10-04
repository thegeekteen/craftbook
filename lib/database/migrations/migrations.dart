import 'package:drift/drift.dart';

import '../app_database.dart';

/// Run database migrations
Future<void> runMigrations(
  AppDatabase db,
  Migrator m,
  int from,
  int to,
) async {
  // Version 1: Initial schema (handled by onCreate)

  // Version 2: Add standalone product support
  if (from < 2) {
    // Add standalone stock columns to products table
    await db.customStatement(
      'ALTER TABLE products ADD COLUMN is_standalone BOOLEAN NOT NULL DEFAULT 0',
    );
    await db.customStatement(
      'ALTER TABLE products ADD COLUMN quantity_on_hand INTEGER NOT NULL DEFAULT 0',
    );
    await db.customStatement(
      'ALTER TABLE products ADD COLUMN quantity_promised INTEGER NOT NULL DEFAULT 0',
    );
    await db.customStatement(
      'ALTER TABLE products ADD COLUMN unit_cost REAL NOT NULL DEFAULT 0.0',
    );
    await db.customStatement(
      'ALTER TABLE products ADD COLUMN alert_level INTEGER NOT NULL DEFAULT 0',
    );

    // Create product stock movements and order products tables
    await db.customStatement(
      'CREATE TABLE product_stock_movements ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'product_id INTEGER NOT NULL, '
      'order_id INTEGER, '
      'type TEXT NOT NULL, '
      'quantity INTEGER NOT NULL, '
      'unit_cost REAL NOT NULL, '
      'created_at INTEGER NOT NULL DEFAULT (STRFTIME(\'%s\', \'now\')), '
      'reference TEXT'
      ')',
    );

    await db.customStatement(
      'CREATE TABLE order_products ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'order_id INTEGER NOT NULL, '
      'product_id INTEGER NOT NULL, '
      'quantity INTEGER NOT NULL, '
      'unit_cost REAL NOT NULL, '
      'created_at INTEGER NOT NULL DEFAULT (STRFTIME(\'%s\', \'now\'))'
      ')',
    );
  }

  // Version 3: product counts stored their difference unsigned, so a count
  // that lowered stock read as an addition. The sign survives only in the
  // reference text ('Adjusted -N units').
  if (from < 3) {
    await db.customStatement(
      "UPDATE product_stock_movements SET quantity = -quantity "
      "WHERE type = 'adjusted' AND reference LIKE 'Adjusted -%' AND quantity > 0",
    );
  }

  // Version 4: the built-in address becomes one of the shop's own order
  // fields. Only shops that actually wrote addresses get an "Address" field.
  // One transaction, so a failure can't leave the tables created but the
  // column still there (every later open would then fail on CREATE TABLE).
  if (from < 4) {
    await db.transaction(() async {
      await db.customStatement(
        'CREATE TABLE "order_field_definitions" ('
        '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"name" TEXT NOT NULL, '
        '"type" TEXT NOT NULL, '
        '"options" TEXT NULL, '
        '"is_multiline" INTEGER NOT NULL DEFAULT 0 CHECK ("is_multiline" IN (0, 1)), '
        '"position" INTEGER NOT NULL DEFAULT 0, '
        '"is_archived" INTEGER NOT NULL DEFAULT 0 CHECK ("is_archived" IN (0, 1)), '
        '"created_at" INTEGER NOT NULL DEFAULT '
        "(CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))"
        ')',
      );
      await db.customStatement(
        'CREATE TABLE "order_field_values" ('
        '"order_id" INTEGER NOT NULL REFERENCES orders (id) ON DELETE CASCADE, '
        '"field_id" INTEGER NOT NULL REFERENCES order_field_definitions (id), '
        '"value" TEXT NOT NULL, '
        'PRIMARY KEY ("order_id", "field_id")'
        ')',
      );
      await db.customStatement(
        'INSERT INTO order_field_definitions (name, type, is_multiline, position) '
        "SELECT 'Address', 'text', 1, 0 WHERE EXISTS "
        "(SELECT 1 FROM orders WHERE TRIM(customer_address) <> '')",
      );
      await db.customStatement(
        'INSERT INTO order_field_values (order_id, field_id, value) '
        'SELECT o.id, d.id, TRIM(o.customer_address) '
        'FROM orders o JOIN order_field_definitions d '
        "ON d.name = 'Address' WHERE TRIM(o.customer_address) <> ''",
      );
      await db
          .customStatement('ALTER TABLE orders DROP COLUMN customer_address');
    });
  }

  // Version 5: the shop's notebook.
  if (from < 5) {
    await db.customStatement(
      'CREATE TABLE "notes" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"title" TEXT NOT NULL DEFAULT \'\', '
      '"body" TEXT NULL, '
      '"is_pinned" INTEGER NOT NULL DEFAULT 0 CHECK ("is_pinned" IN (0, 1)), '
      '"created_at" INTEGER NOT NULL DEFAULT '
      "(CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)), "
      '"updated_at" INTEGER NOT NULL DEFAULT '
      "(CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))"
      ')',
    );
  }
}
