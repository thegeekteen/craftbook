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

  // Version 6: social shortcuts.
  if (from < 6) {
    await db.customStatement(
      'CREATE TABLE "social_links" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"platform" TEXT NOT NULL, '
      '"label" TEXT NOT NULL, '
      '"url" TEXT NOT NULL, '
      '"color_value" INTEGER NULL, '
      '"position" INTEGER NOT NULL DEFAULT 0'
      ')',
    );
  }

  // Version 7: product photos.
  if (from < 7) {
    await db.customStatement('ALTER TABLE products ADD COLUMN photo BLOB');
  }

  // Version 8: archiving replaces the product's "show in new orders" switch,
  // and materials can be archived too. A hidden product becomes archived.
  if (from < 8) {
    await db.transaction(() async {
      const column = '"is_archived" INTEGER NOT NULL DEFAULT 0 '
          'CHECK ("is_archived" IN (0, 1))';
      await db.customStatement('ALTER TABLE products ADD COLUMN $column');
      await db.customStatement('ALTER TABLE materials ADD COLUMN $column');
      await db.customStatement(
          'UPDATE products SET is_archived = 1 WHERE is_active = 0');
      await db.customStatement('ALTER TABLE products DROP COLUMN is_active');
    });
  }

  // Version 9: discounts, tax and paid status on orders, discount presets,
  // and a per-channel "paid when placed" default. Orders from before this
  // had no way to be unpaid, so they all start paid.
  if (from < 9) {
    await db.transaction(() async {
      String flag(String name, int value) =>
          '"$name" INTEGER NOT NULL DEFAULT $value CHECK ("$name" IN (0, 1))';
      for (final column in [
        '"discount_total" REAL NOT NULL DEFAULT 0.0',
        '"tax_rate" REAL NULL',
        '"tax_amount" REAL NOT NULL DEFAULT 0.0',
        flag('tax_inclusive', 1),
        flag('is_paid', 1),
        '"paid_at" INTEGER NULL',
      ]) {
        await db.customStatement('ALTER TABLE orders ADD COLUMN $column');
      }
      await db.customStatement(
          'UPDATE orders SET paid_at = COALESCE(shipped_at, packed_at, order_date)');
      await db.customStatement(
          'ALTER TABLE channels ADD COLUMN ${flag('paid_by_default', 1)}');
      await db.customStatement(
        'CREATE TABLE "order_discounts" ('
        '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"order_id" INTEGER NOT NULL REFERENCES orders (id) ON DELETE CASCADE, '
        '"label" TEXT NOT NULL, '
        '"kind" TEXT NOT NULL, '
        '"value" REAL NOT NULL, '
        '"amount" REAL NOT NULL, '
        '"position" INTEGER NOT NULL DEFAULT 0'
        ')',
      );
      await db.customStatement(
        'CREATE TABLE "discount_presets" ('
        '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        '"label" TEXT NOT NULL, '
        '"kind" TEXT NOT NULL, '
        '"value" REAL NOT NULL, '
        '"position" INTEGER NOT NULL DEFAULT 0, '
        '"created_at" INTEGER NOT NULL DEFAULT '
        "(CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))"
        ')',
      );
    });
  }
}
