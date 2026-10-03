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
}
