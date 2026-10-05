import 'package:drift/drift.dart';

import 'units_table.dart';

/// Materials table - raw materials/inventory
class Materials extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// What the quantities below are counted in; see [Units]. The repository
  /// always writes the shop's real default; this one only matches it so a
  /// fresh database and a migrated one have the same schema. The literal is
  /// `AppConstants.defaultUnitId` — Drift copies it into generated code,
  /// which can't see that import, and `migration_v11_test` checks they agree.
  IntColumn get unitId => integer().withDefault(const Constant(1))();

  /// Fractions are real stock: a Bubble Head uses 1.25 boards, a card uses a
  /// ninth of a sheet.
  RealColumn get packSize => real()();
  RealColumn get packPrice => real()();
  RealColumn get unitCost => real()();
  RealColumn get quantityOnHand => real().withDefault(const Constant(0))();
  RealColumn get quantityPromised => real().withDefault(const Constant(0))();
  RealColumn get alertLevel => real()();
  TextColumn get supplier => text().nullable()();
  DateTimeColumn get lastReceivedAt => dateTime().nullable()();

  /// Archived materials are kept for past orders but left out of lists,
  /// pickers, alerts and the buy list.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
