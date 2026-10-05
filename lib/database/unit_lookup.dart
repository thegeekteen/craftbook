import 'package:drift/drift.dart';

import 'app_database.dart';

/// Resolving the `unit_id` columns on materials and products.
///
/// Units are a small lookup table that only changes on the Units screen, so
/// reads fetch the whole map once and resolve from it instead of joining
/// `units` into every query.
extension UnitLookup on AppDatabase {
  /// Every unit label by id.
  Future<Map<int, String>> unitLabels() async {
    final rows = await select(units).get();
    return {for (final u in rows) u.id: u.label};
  }

  /// The unit new materials and products start on: the flagged one, or the
  /// first in the list when nothing is flagged. Null only when the list is
  /// empty, which a seeded database never is.
  Future<int?> defaultUnitId() async {
    final rows = await (select(units)
          ..orderBy([
            (t) => OrderingTerm.asc(t.position),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
    if (rows.isEmpty) return null;
    return rows.firstWhere((u) => u.isDefault, orElse: () => rows.first).id;
  }
}
