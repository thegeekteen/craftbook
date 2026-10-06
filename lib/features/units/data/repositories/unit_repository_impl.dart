import 'package:drift/drift.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/unit_dao.dart';
import '../../domain/entities/unit_of_measure.dart';
import '../../domain/repositories/unit_repository.dart';

class UnitRepositoryImpl implements UnitRepository {
  final UnitDao dao;

  UnitRepositoryImpl(this.dao);

  @override
  Future<Result<List<UnitOfMeasure>>> getUnits() async {
    try {
      final rows = await dao.getAll();
      return Success([for (final row in rows) _toEntity(row)]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<UnitOfMeasure?>> getDefaultUnit() async {
    try {
      final row = await dao.getDefault();
      return Success(row == null ? null : _toEntity(row));
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> createUnit(UnitOfMeasure unit) async {
    try {
      final id = await dao.transaction(() async {
        return dao.insertUnit(db.UnitsCompanion.insert(
          label: unit.label,
          position: Value(await dao.nextPosition()),
        ));
      });
      return Success(id);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateUnit(UnitOfMeasure unit) async {
    try {
      final updated = await dao.updateUnit(
        unit.id!,
        db.UnitsCompanion(label: Value(unit.label)),
      );
      if (updated == 0) {
        return const Error(NotFoundFailure('Unit not found'));
      }
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteUnit(int id) async {
    try {
      await dao.transaction(() async {
        final doomed = await dao.getById(id);
        await dao.deleteUnit(id);
        // Deleting the default hands it to the next unit in the list, so new
        // items always have one to start on.
        if (doomed != null && doomed.isDefault) {
          final next = await dao.getDefault();
          if (next != null) await dao.setDefault(next.id);
        }
      });
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

  @override
  Future<Result<void>> setDefaultUnit(int id) async {
    try {
      await dao.setDefault(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<(int, int)>> usageCounts(int unitId) async {
    try {
      return Success(await dao.usageCounts(unitId));
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  static UnitOfMeasure _toEntity(db.Unit row) => UnitOfMeasure(
        id: row.id,
        label: row.label,
        position: row.position,
        isDefault: row.isDefault,
      );
}
