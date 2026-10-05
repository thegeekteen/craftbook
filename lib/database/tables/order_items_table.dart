import 'package:drift/drift.dart';

/// Order items table - products within an order
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer()();
  IntColumn get productId => integer()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get subtotal => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
