import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/materials_table.dart';
import '../tables/products_table.dart';
import '../tables/units_table.dart';

part 'unit_dao.g.dart';

/// Data Access Object for units of measure
@DriftAccessor(tables: [Units, Materials, Products])
class UnitDao extends DatabaseAccessor<AppDatabase> with _$UnitDaoMixin {
  UnitDao(super.db);

  Future<List<Unit>> getAll() {
    return (select(units)
          ..orderBy([
            (t) => OrderingTerm.asc(t.position),
            (t) => OrderingTerm.asc(t.id)
          ]))
        .get();
  }

  Future<Unit?> getById(int id) {
    return (select(units)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// The unit new materials and products start on, or null when the list is
  /// empty.
  Future<Unit?> getDefault() async {
    final all = await getAll();
    for (final unit in all) {
      if (unit.isDefault) return unit;
    }
    return all.isEmpty ? null : all.first;
  }

  /// Whether [label] is already taken by another unit. Labels are UNIQUE in
  /// the schema; checking first gives a readable message instead of an
  /// exception.
  Future<bool> labelTaken(String label, {int? exceptId}) async {
    final query = select(units)..where((t) => t.label.equals(label));
    if (exceptId != null) {
      query.where((t) => t.id.equals(exceptId).not());
    }
    return (await query.get()).isNotEmpty;
  }

  Future<int> nextPosition() async {
    final max = units.position.max();
    final query = selectOnly(units)..addColumns([max]);
    final current = (await query.getSingle()).read(max);
    return current == null ? 0 : current + 1;
  }

  Future<int> insertUnit(UnitsCompanion unit) => into(units).insert(unit);

  Future<int> updateUnit(int id, UnitsCompanion unit) {
    return (update(units)..where((t) => t.id.equals(id))).write(unit);
  }

  Future<int> deleteUnit(int id) =>
      (delete(units)..where((t) => t.id.equals(id))).go();

  /// Writes positions in list order, in one transaction.
  Future<void> setPositions(List<int> ids) {
    return transaction(() async {
      for (var i = 0; i < ids.length; i++) {
        await updateUnit(ids[i], UnitsCompanion(position: Value(i)));
      }
    });
  }

  /// Flags [id] as the default and clears the flag everywhere else, so exactly
  /// one unit is ever the default.
  Future<void> setDefault(int id) {
    return transaction(() async {
      await customStatement('UPDATE units SET is_default = 0');
      await updateUnit(id, const UnitsCompanion(isDefault: Value(true)));
    });
  }

  /// How many materials and products are counted in [unitId]. A unit in use
  /// can't be deleted.
  Future<(int, int)> usageCounts(int unitId) async {
    Future<int> count(String table) => customSelect(
          'SELECT COUNT(*) AS cnt FROM $table WHERE unit_id = ?',
          variables: [Variable.withInt(unitId)],
        ).getSingle().then((r) => r.read<int>('cnt'));
    return (await count('materials'), await count('products'));
  }

  Future<int> countAll() async {
    final result =
        await customSelect('SELECT COUNT(*) AS cnt FROM units').getSingle();
    return result.read<int>('cnt');
  }
}
