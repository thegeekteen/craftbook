import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/orders_table.dart';

part 'discount_preset_dao.g.dart';

/// Data Access Object for discount presets
@DriftAccessor(tables: [DiscountPresets])
class DiscountPresetDao extends DatabaseAccessor<AppDatabase>
    with _$DiscountPresetDaoMixin {
  DiscountPresetDao(super.db);

  Future<List<DiscountPreset>> getAll() {
    return (select(discountPresets)
          ..orderBy([
            (t) => OrderingTerm.asc(t.position),
            (t) => OrderingTerm.asc(t.id)
          ]))
        .get();
  }

  Future<int> nextPosition() async {
    final max = discountPresets.position.max();
    final query = selectOnly(discountPresets)..addColumns([max]);
    final current = (await query.getSingle()).read(max);
    return current == null ? 0 : current + 1;
  }

  Future<int> insertPreset(DiscountPresetsCompanion preset) =>
      into(discountPresets).insert(preset);

  Future<int> updatePreset(int id, DiscountPresetsCompanion preset) {
    return (update(discountPresets)..where((t) => t.id.equals(id)))
        .write(preset);
  }

  Future<int> deletePreset(int id) =>
      (delete(discountPresets)..where((t) => t.id.equals(id))).go();

  /// Writes positions in list order, in one transaction.
  Future<void> setPositions(List<int> ids) {
    return transaction(() async {
      for (var i = 0; i < ids.length; i++) {
        await updatePreset(
            ids[i], DiscountPresetsCompanion(position: Value(i)));
      }
    });
  }
}
