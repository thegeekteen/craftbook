import 'package:sqlite3/sqlite3.dart' as raw;

/// Turns a current database back into schema 10, from before units of measure.
void downgradeToV10(raw.Database db) {
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
