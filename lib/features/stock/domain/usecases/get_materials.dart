import '../../../../core/error/result.dart';
import '../entities/material.dart';
import '../repositories/material_repository.dart';

class GetMaterials {
  final MaterialRepository repository;

  GetMaterials(this.repository);

  /// Low stock never includes archived materials. Pickers pass
  /// [includeArchived] false; lists load everything and filter on screen.
  Future<Result<List<Material>>> call({
    bool lowStockOnly = false,
    bool includeArchived = true,
  }) async {
    if (lowStockOnly) {
      return repository.getLowStockMaterials();
    }
    final result = await repository.getAllMaterials();
    if (includeArchived) return result;
    return switch (result) {
      Success(:final value) =>
        Success(value.where((m) => !m.isArchived).toList()),
      Error() => result,
    };
  }
}
