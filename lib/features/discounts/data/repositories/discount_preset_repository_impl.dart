import 'package:drift/drift.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/discount_preset_dao.dart';
import '../../../orders/domain/entities/order_discount.dart';
import '../../domain/entities/discount_preset.dart';
import '../../domain/repositories/discount_preset_repository.dart';

class DiscountPresetRepositoryImpl implements DiscountPresetRepository {
  final DiscountPresetDao dao;

  DiscountPresetRepositoryImpl(this.dao);

  @override
  Future<Result<List<DiscountPreset>>> getPresets() async {
    try {
      final rows = await dao.getAll();
      return Success([for (final row in rows) _toEntity(row)]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> createPreset(DiscountPreset preset) async {
    try {
      final id = await dao.transaction(() async {
        return dao.insertPreset(db.DiscountPresetsCompanion.insert(
          label: preset.label,
          kind: preset.kind.name,
          value: preset.value,
          position: Value(await dao.nextPosition()),
        ));
      });
      return Success(id);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updatePreset(DiscountPreset preset) async {
    try {
      final updated = await dao.updatePreset(
        preset.id!,
        db.DiscountPresetsCompanion(
          label: Value(preset.label),
          kind: Value(preset.kind.name),
          value: Value(preset.value),
        ),
      );
      if (updated == 0) {
        return const Error(NotFoundFailure('Discount not found'));
      }
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePreset(int id) async {
    try {
      await dao.deletePreset(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> reorder(List<int> ids) async {
    try {
      await dao.setPositions(ids);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  static DiscountPreset _toEntity(db.DiscountPreset row) => DiscountPreset(
        id: row.id,
        label: row.label,
        kind: DiscountKind.fromName(row.kind),
        value: row.value,
        position: row.position,
      );
}
