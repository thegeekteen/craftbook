import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../repositories/material_repository.dart';

class UpdateMaterial {
  final MaterialRepository repository;

  UpdateMaterial(this.repository);

  Future<Result<void>> call({
    required int id,
    required String name,
    int? unitId,
    required double packSize,
    required double packPrice,
    required double alertLevel,
    String? supplier,
  }) async {
    if (name.trim().isEmpty) {
      return const Error(ValidationFailure('Enter a name'));
    }
    if (packSize <= 0) {
      return const Error(ValidationFailure('Pack size must be above 0'));
    }
    if (packPrice < 0) {
      return const Error(ValidationFailure('Pack price cannot be negative'));
    }
    if (alertLevel < 0) {
      return const Error(ValidationFailure('Reorder level cannot be negative'));
    }
    final trimmedSupplier = supplier?.trim();
    return repository.updateMaterial(
      id: id,
      name: name.trim(),
      unitId: unitId,
      packSize: packSize,
      packPrice: packPrice,
      alertLevel: alertLevel,
      supplier: trimmedSupplier == null || trimmedSupplier.isEmpty
          ? null
          : trimmedSupplier,
    );
  }
}
