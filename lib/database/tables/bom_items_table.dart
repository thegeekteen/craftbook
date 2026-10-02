import 'package:drift/drift.dart';

/// BOM items table - bill of materials for products
class BomItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()();
  IntColumn get materialId => integer()();
  IntColumn get quantityRequired => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
