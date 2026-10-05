import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../orders/domain/entities/order_discount.dart';
import '../entities/discount_preset.dart';
import '../repositories/discount_preset_repository.dart';

class GetDiscountPresets {
  final DiscountPresetRepository repository;

  GetDiscountPresets(this.repository);

  Future<Result<List<DiscountPreset>>> call() => repository.getPresets();
}

/// Adds a preset when [id] is null, otherwise edits it.
class SaveDiscountPreset {
  final DiscountPresetRepository repository;

  SaveDiscountPreset(this.repository);

  Future<Result<void>> call({
    int? id,
    required String label,
    required DiscountKind kind,
    required double value,
  }) async {
    final invalid = validateDiscount(label: label, kind: kind, value: value);
    if (invalid != null) return Error(invalid);
    final preset =
        DiscountPreset(id: id, label: label.trim(), kind: kind, value: value);
    if (id == null) {
      final created = await repository.createPreset(preset);
      return switch (created) {
        Success() => const Success(null),
        Error(:final failure) => Error(failure),
      };
    }
    return repository.updatePreset(preset);
  }
}

class DeleteDiscountPreset {
  final DiscountPresetRepository repository;

  DeleteDiscountPreset(this.repository);

  Future<Result<void>> call(int id) => repository.deletePreset(id);
}

/// Sets the order presets are shown in.
class ReorderDiscountPresets {
  final DiscountPresetRepository repository;

  ReorderDiscountPresets(this.repository);

  Future<Result<void>> call(List<int> orderedIds) async {
    if (orderedIds.toSet().length != orderedIds.length) {
      return const Error(ValidationFailure('A discount appears twice'));
    }
    return repository.reorder(orderedIds);
  }
}

/// Why a discount can't be saved, or null when it can. Shared by presets
/// and discounts typed in on an order.
ValidationFailure? validateDiscount({
  required String label,
  required DiscountKind kind,
  required double value,
}) {
  if (label.trim().isEmpty) {
    return const ValidationFailure('Give the discount a name');
  }
  if (value <= 0) {
    return const ValidationFailure('Enter an amount above zero');
  }
  if (kind == DiscountKind.percent && value > 100) {
    return const ValidationFailure('A percentage can be at most 100');
  }
  return null;
}
