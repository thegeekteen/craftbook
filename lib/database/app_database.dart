import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/orders_table.dart';
import 'tables/order_items_table.dart';
import 'tables/order_materials_table.dart';
import 'tables/materials_table.dart';
import 'tables/products_table.dart';
import 'tables/bom_items_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/settings_table.dart';
import 'migrations/migrations.dart';

part 'app_database.g.dart';

/// Main Drift database class
@DriftDatabase(
  tables: [
    Orders,
    OrderItems,
    OrderMaterials,
    Materials,
    Products,
    BomItems,
    Channels,
    StockMovements,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        await runMigrations(m, from, to);
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(documentsFolder.path, 'craftbook.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
