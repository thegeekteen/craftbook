import 'package:drift/drift.dart';

/// Order materials table - materials used in an order
class OrderMaterials extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer()();
  IntColumn get materialId => integer()();
  IntColumn get plannedQuantity => integer()();
  IntColumn get actualQuantity => integer()();
  IntColumn get wasteQuantity => integer().withDefault(const Constant(0))();
  TextColumn get wasteReason => text().nullable()();
  RealColumn get unitCost => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
