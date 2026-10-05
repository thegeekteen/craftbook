import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/unit_of_measure.dart';
import '../repositories/unit_repository.dart';

/// Longest label allowed. A unit sits next to every number in the app,
/// including tight spots like "₱3.00/sheet", so it has to stay short.
const maxUnitLabelLength = 20;

class GetUnits {
  final UnitRepository repository;

  GetUnits(this.repository);

  Future<Result<List<UnitOfMeasure>>> call() => repository.getUnits();
}

/// The unit the material and product forms start on.
class GetDefaultUnit {
  final UnitRepository repository;

  GetDefaultUnit(this.repository);

  Future<Result<UnitOfMeasure?>> call() => repository.getDefaultUnit();
}

/// Adds a unit when [id] is null, otherwise renames it. Renaming reaches every
/// item and every past order that shows the unit, since they point at the row.
class SaveUnit {
  final UnitRepository repository;

  SaveUnit(this.repository);

  Future<Result<void>> call({int? id, required String label}) async {
    final invalid = await validateUnitLabel(repository, label: label, id: id);
    if (invalid != null) return Error(invalid);
    final unit = UnitOfMeasure(id: id, label: label.trim());
    if (id == null) {
      final created = await repository.createUnit(unit);
      return switch (created) {
        Success() => const Success(null),
        Error(:final failure) => Error(failure),
      };
    }
    return repository.updateUnit(unit);
  }
}

class DeleteUnit {
  final UnitRepository repository;

  DeleteUnit(this.repository);

  Future<Result<void>> call(int id) async {
    final units = await repository.getUnits();
    if (units case Error(:final failure)) return Error(failure);
    if ((units as Success<List<UnitOfMeasure>>).value.length <= 1) {
      return const Error(ValidationFailure(
        'Keep at least one unit — everything is counted in one.',
      ));
    }

    final usage = await repository.usageCounts(id);
    if (usage case Error(:final failure)) return Error(failure);
    switch ((usage as Success<(int, int)>).value) {
      case (final materials, final products) when materials > 0 || products > 0:
        final usedBy = [
          if (materials > 0) _plural(materials, 'material'),
          if (products > 0) _plural(products, 'product'),
        ].join(' and ');
        return Error(ValidationFailure(
          'Cannot delete unit: $usedBy are counted in it. '
          'Move them to another unit first.',
        ));
      default:
        break;
    }

    return repository.deleteUnit(id);
  }

  static String _plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
}

/// Sets the order units are listed in.
class ReorderUnits {
  final UnitRepository repository;

  ReorderUnits(this.repository);

  Future<Result<void>> call(List<int> orderedIds) async {
    if (orderedIds.toSet().length != orderedIds.length) {
      return const Error(ValidationFailure('A unit appears twice'));
    }
    return repository.reorder(orderedIds);
  }
}

/// Makes a unit the one new materials and products start on.
class SetDefaultUnit {
  final UnitRepository repository;

  SetDefaultUnit(this.repository);

  Future<Result<void>> call(int id) => repository.setDefaultUnit(id);
}

/// Why a unit can't be saved, or null when it can. Compares case-insensitively
/// so "PC" can't sneak in next to "pc".
Future<ValidationFailure?> validateUnitLabel(
  UnitRepository repository, {
  required String label,
  int? id,
}) async {
  final trimmed = label.trim();
  if (trimmed.isEmpty) {
    return const ValidationFailure('Give the unit a name');
  }
  if (trimmed.length > maxUnitLabelLength) {
    return const ValidationFailure(
      'Keep it under $maxUnitLabelLength characters — it shows next to '
      'every number',
    );
  }
  final units = await repository.getUnits();
  if (units case Success(:final value)) {
    final taken = value.any(
        (u) => u.id != id && u.label.toLowerCase() == trimmed.toLowerCase());
    if (taken) {
      return ValidationFailure('You already have a unit called "$trimmed"');
    }
  }
  return null;
}
