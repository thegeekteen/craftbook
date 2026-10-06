import 'package:drift/drift.dart';

/// Product stock movements table - tracks all stock changes for standalone products
class ProductStockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()();
  IntColumn get orderId => integer().nullable()();
  TextColumn get type => text()(); // 'received', 'deducted', 'adjusted'
  RealColumn get quantity => real()();
  RealColumn get unitCost => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get reference => text().nullable()();
}
