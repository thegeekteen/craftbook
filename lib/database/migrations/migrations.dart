import 'package:drift/drift.dart';

/// Run database migrations
Future<void> runMigrations(Migrator m, int from, int to) async {
  // Version 1: Initial schema (handled by onCreate)
  
  // Future migrations go here
  // Example:
  // if (from < 2) {
  //   await m.alterTable(TableMigration.orders);
  // }
}
