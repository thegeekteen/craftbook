import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/order_fields_table.dart';

part 'order_field_dao.g.dart';

/// Data Access Object for order field definitions
@DriftAccessor(tables: [OrderFieldDefinitions, OrderFieldValues])
class OrderFieldDao extends DatabaseAccessor<AppDatabase>
    with _$OrderFieldDaoMixin {
  OrderFieldDao(super.db);

  /// Every definition with how many orders hold a value for it, by position.
  Future<List<(OrderFieldDefinition, int)>> getDefinitionsWithUsage() async {
    final usage = orderFieldValues.orderId.count();
    final query = select(orderFieldDefinitions).join([
      leftOuterJoin(
        orderFieldValues,
        orderFieldValues.fieldId.equalsExp(orderFieldDefinitions.id),
      ),
    ])
      ..addColumns([usage])
      ..groupBy([orderFieldDefinitions.id])
      ..orderBy([
        OrderingTerm.asc(orderFieldDefinitions.position),
        OrderingTerm.asc(orderFieldDefinitions.id),
      ]);
    final rows = await query.get();
    return [
      for (final r in rows)
        (r.readTable(orderFieldDefinitions), r.read(usage) ?? 0),
    ];
  }

  Future<int> usageCount(int fieldId) async {
    final count = orderFieldValues.orderId.count();
    final query = selectOnly(orderFieldValues)
      ..addColumns([count])
      ..where(orderFieldValues.fieldId.equals(fieldId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<int> nextPosition() async {
    final max = orderFieldDefinitions.position.max();
    final query = selectOnly(orderFieldDefinitions)..addColumns([max]);
    final current = (await query.getSingle()).read(max);
    return current == null ? 0 : current + 1;
  }

  Future<int> insertDefinition(OrderFieldDefinitionsCompanion field) {
    return into(orderFieldDefinitions).insert(field);
  }

  Future<int> updateDefinition(int id, OrderFieldDefinitionsCompanion field) {
    return (update(orderFieldDefinitions)..where((t) => t.id.equals(id)))
        .write(field);
  }

  Future<int> deleteDefinition(int id) {
    return (delete(orderFieldDefinitions)..where((t) => t.id.equals(id))).go();
  }

  /// Writes positions in list order, in one transaction.
  Future<void> setPositions(List<int> ids) {
    return transaction(() async {
      for (var i = 0; i < ids.length; i++) {
        await updateDefinition(
          ids[i],
          OrderFieldDefinitionsCompanion(position: Value(i)),
        );
      }
    });
  }
}
