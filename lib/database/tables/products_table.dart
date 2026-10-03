import 'package:drift/drift.dart';

/// Products table - sellable products
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get sellPrice => real()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isStandalone => boolean().withDefault(const Constant(false))();
  IntColumn get quantityOnHand => integer().withDefault(const Constant(0))();
  IntColumn get quantityPromised => integer().withDefault(const Constant(0))();
  RealColumn get unitCost => real().withDefault(const Constant(0.0))();
  IntColumn get alertLevel => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
