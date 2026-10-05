import 'package:drift/drift.dart';

/// Units of measure a material or product is counted in ("pc", "sheet", "kg").
///
/// Items hold a `unit_id` pointing here rather than their own copy of the
/// text, so renaming a unit updates every item and every past order that
/// shows it. Labels render exactly as typed — the app never pluralises them.
class Units extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text().unique()();
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// The unit new materials and products start on. Exactly one row has it.
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
