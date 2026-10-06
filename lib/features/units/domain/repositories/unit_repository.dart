import '../../../../core/error/result.dart';
import '../entities/unit_of_measure.dart';

abstract class UnitRepository {
  /// In the order they're listed.
  Future<Result<List<UnitOfMeasure>>> getUnits();

  /// The unit new materials and products start on. Null only when the list is
  /// empty, which the delete rules prevent.
  Future<Result<UnitOfMeasure?>> getDefaultUnit();

  /// Adds [unit] at the end of the list.
  Future<Result<int>> createUnit(UnitOfMeasure unit);
  Future<Result<void>> updateUnit(UnitOfMeasure unit);
  Future<Result<void>> deleteUnit(int id);

  /// Sets the order units are listed in.
  Future<Result<void>> reorder(List<int> ids);

  /// Makes [id] the unit new items start on, clearing it everywhere else.
  Future<Result<void>> setDefaultUnit(int id);

  /// How many materials and products are counted in [unitId]. A unit in use
  /// can't be deleted, because their quantities would lose their meaning.
  Future<Result<(int, int)>> usageCounts(int unitId);
}
