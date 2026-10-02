import 'package:drift/drift.dart';

/// Materials table - raw materials/inventory
class Materials extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get packSize => integer()();
  RealColumn get packPrice => real()();
  RealColumn get unitCost => real()();
  IntColumn get quantityOnHand => integer().withDefault(const Constant(0))();
  IntColumn get quantityPromised => integer().withDefault(const Constant(0))();
  IntColumn get alertLevel => integer()();
  TextColumn get supplier => text().nullable()();
  DateTimeColumn get lastReceivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
