import 'package:drift/drift.dart';

import 'orders_table.dart';

/// Extra details the shop wants noted on each order (address, size, wrap…).
class OrderFieldDefinitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// 'text' | 'number' | 'date' | 'choice'
  TextColumn get type => text()();

  /// JSON list of option labels; only set for choice fields.
  TextColumn get options => text().nullable()();
  BoolColumn get isMultiline => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// Archived fields are no longer asked for, but past orders keep their
  /// values.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// One order's value for one field. No row means the field is empty.
class OrderFieldValues extends Table {
  IntColumn get orderId =>
      integer().references(Orders, #id, onDelete: KeyAction.cascade)();

  // No delete action: the database refuses to drop a field orders still use.
  IntColumn get fieldId => integer().references(OrderFieldDefinitions, #id)();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {orderId, fieldId};
}
