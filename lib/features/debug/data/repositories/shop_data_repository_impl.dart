import 'package:drift/drift.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' hide Note, SocialLink;
import '../../../../database/migrations/migrations.dart';
import '../../domain/repositories/shop_data_repository.dart';

/// Writes straight through Drift, for the debug tools only.
class ShopDataRepositoryImpl implements ShopDataRepository {
  final AppDatabase db;

  ShopDataRepositoryImpl(this.db);

  @override
  int get schemaVersion => AppDatabase.currentSchemaVersion;

  @override
  Future<T> inTransaction<T>(Future<T> Function() work) => db.transaction(work);

  @override
  Future<Result<void>> wipeAll() async {
    try {
      await db.transaction(() async {
        // Children before parents: the file keeps foreign keys on, so an order
        // that still names a material would refuse to let it go.
        await db.delete(db.orderItems).go();
        await db.delete(db.orderMaterials).go();
        await db.delete(db.orderProducts).go();
        await db.delete(db.orderFieldValues).go();
        await db.delete(db.orderDiscounts).go();
        await db.delete(db.stockMovements).go();
        await db.delete(db.productStockMovements).go();
        await db.delete(db.bomItems).go();
        await db.delete(db.orders).go();
        await db.delete(db.notes).go();
        await db.delete(db.socialLinks).go();
        await db.delete(db.discountPresets).go();
        await db.delete(db.orderFieldDefinitions).go();
        await db.delete(db.products).go();
        await db.delete(db.materials).go();
        await db.delete(db.channels).go();
        await db.delete(db.settings).go();
        // Units belong to the schema rather than the shop, so a fresh install
        // has them and so does a wipe. seedUnits leaves existing rows alone.
        await db.delete(db.units).go();
        // Every shop table ids from AUTOINCREMENT and deleting rows doesn't
        // move the counter, so without this the second seed of the same seed
        // number writes order 35 instead of order 1 — which is exactly the
        // comparability a fixed seed exists to give.
        final counters = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' "
              "AND name = 'sqlite_sequence'",
            )
            .get();
        if (counters.isNotEmpty) {
          await db.customStatement('DELETE FROM sqlite_sequence');
        }
        await seedUnits(db);
      });
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, int>>> tableCounts() async {
    try {
      final names = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .get();
      final counts = <String, int>{};
      for (final row in names) {
        final table = row.read<String>('name');
        final counted = await db
            .customSelect('SELECT COUNT(*) AS total FROM "$table"')
            .getSingle();
        counts[table] = counted.read<int>('total');
      }
      return Success(counts);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> location() async {
    try {
      final row = await db.customSelect('PRAGMA database_list').get();
      for (final entry in row) {
        final path = entry.read<String>('file');
        if (path.isNotEmpty) return Success(path);
      }
      return const Success('in memory');
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> backdateOrder({
    required int orderId,
    DateTime? packedAt,
    DateTime? shippedAt,
  }) async {
    try {
      await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          packedAt: packedAt == null ? const Value.absent() : Value(packedAt),
          shippedAt:
              shippedAt == null ? const Value.absent() : Value(shippedAt),
        ),
      );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> backdateStockHistory({
    int? materialId,
    int? productId,
    required int days,
  }) async {
    final shift = Duration(days: days);
    try {
      if (materialId != null) {
        final rows = await (db.select(db.stockMovements)
              ..where((t) => t.materialId.equals(materialId)))
            .get();
        for (final row in rows) {
          await (db.update(db.stockMovements)
                ..where((t) => t.id.equals(row.id)))
              .write(StockMovementsCompanion(
                  createdAt: Value(row.createdAt.subtract(shift))));
        }
      }
      if (productId != null) {
        final rows = await (db.select(db.productStockMovements)
              ..where((t) => t.productId.equals(productId)))
            .get();
        for (final row in rows) {
          await (db.update(db.productStockMovements)
                ..where((t) => t.id.equals(row.id)))
              .write(ProductStockMovementsCompanion(
                  createdAt: Value(row.createdAt.subtract(shift))));
        }
      }
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }
}
