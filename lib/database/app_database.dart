import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/orders_table.dart';
import 'tables/order_items_table.dart';
import 'tables/order_materials_table.dart';
import 'tables/order_products_table.dart';
import 'tables/materials_table.dart';
import 'tables/products_table.dart';
import 'tables/bom_items_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/product_stock_movements_table.dart';
import 'tables/settings_table.dart';
import 'tables/order_fields_table.dart';
import 'tables/notes_table.dart';
import 'tables/social_links_table.dart';
import 'migrations/migrations.dart';

part 'app_database.g.dart';

/// Stamped into the SQLite header (`PRAGMA application_id`, 'CRFT') so a
/// backup can be told apart from another app's database.
const craftbookAppId = 0x43524654;

/// Main Drift database class
@DriftDatabase(
  tables: [
    Orders,
    OrderItems,
    OrderMaterials,
    OrderProducts,
    Materials,
    Products,
    BomItems,
    Channels,
    StockMovements,
    ProductStockMovements,
    Settings,
    OrderFieldDefinitions,
    OrderFieldValues,
    Notes,
    SocialLinks,
    OrderDiscounts,
    DiscountPresets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing
  AppDatabase.forTesting(super.e);

  /// Opens [file] on the calling isolate. Used to trial-migrate a backup.
  AppDatabase.file(File file) : super(NativeDatabase(file));

  /// Readable without opening a database, so a backup's version can be
  /// checked before anything touches it.
  static const currentSchemaVersion = 9;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        await runMigrations(this, m, from, to);
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('PRAGMA application_id = $craftbookAppId');
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
