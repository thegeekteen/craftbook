import 'package:drift/drift.dart';

/// Stock movements table - tracks all stock changes
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get materialId => integer()();
  IntColumn get orderId => integer().nullable()();
  TextColumn get type => text()(); // 'received', 'deducted', 'adjusted', 'waste'
  IntColumn get quantity => integer()();
  RealColumn get unitCost => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get reference => text().nullable()();
}
