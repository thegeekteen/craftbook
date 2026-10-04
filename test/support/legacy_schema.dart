import 'package:sqlite3/sqlite3.dart' as raw;

/// Turns a current database back into schema 5, from before social shortcuts.
void downgradeToV5(raw.Database db) {
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
