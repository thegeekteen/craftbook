import 'package:drift/drift.dart';

import 'units_table.dart';

/// Products table - sellable products
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get sellPrice => real()();

  /// What this is sold and counted in; see [Units]. The repository always
  /// writes the shop's real default; this one only matches it so a fresh
  /// database and a migrated one have the same schema. The literal is
  /// `AppConstants.defaultUnitId`, checked by `migration_v11_test`.
  IntColumn get unitId => integer().withDefault(const Constant(1))();

  /// Archived products are kept for past orders but left out of lists,
  /// pickers, alerts and the buy list.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isStandalone => boolean().withDefault(const Constant(false))();
  IntColumn get quantityOnHand => integer().withDefault(const Constant(0))();
  IntColumn get quantityPromised => integer().withDefault(const Constant(0))();
  RealColumn get unitCost => real().withDefault(const Constant(0.0))();
  IntColumn get alertLevel => integer().withDefault(const Constant(0))();

  /// Resized JPEG. Kept in the database so a raw sqlite backup carries it.
  BlobColumn get photo => blob().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
