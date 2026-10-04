import '../../../../core/error/result.dart';
import '../repositories/material_repository.dart';

/// Archives a material that can't be deleted (or shouldn't be yet), or
/// brings it back. Archived materials stay on past orders.
class SetMaterialArchived {
  final MaterialRepository repository;

  SetMaterialArchived(this.repository);

  Future<Result<void>> call(int materialId, {required bool archived}) =>
      repository.setMaterialArchived(materialId, archived);
}
