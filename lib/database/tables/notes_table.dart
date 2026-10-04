import 'package:drift/drift.dart';

/// The shop's own notebook: ideas, supplier details, how-tos. Not tied to any
/// order, material or product.
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();

  /// Quill Delta JSON, read and written through `NoteCodec`.
  TextColumn get body => text().nullable()();

  /// Pinned notes sort first and show on Today.
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
