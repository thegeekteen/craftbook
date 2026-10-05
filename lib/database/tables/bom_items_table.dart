import 'package:drift/drift.dart';

/// BOM items table - bill of materials for products
class BomItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()();
  IntColumn get materialId => integer()();
  RealColumn get quantityRequired => real()();

  /// How many products [quantityRequired] pieces make, e.g. one A4 sheet
  /// makes 9 business cards. 1 means the pieces go into a single product.
  RealColumn get makes => real().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
