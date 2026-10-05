import 'package:drift/drift.dart';

/// Order products table - standalone products reserved/deducted for an order
class OrderProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer()();
  IntColumn get productId => integer()();
  RealColumn get quantity => real()();
  RealColumn get unitCost => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
