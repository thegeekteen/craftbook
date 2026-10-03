import '../../../../core/error/result.dart';
import '../../../stock/domain/repositories/material_repository.dart';

class ReserveMaterials {
  final MaterialRepository repository;

  ReserveMaterials(this.repository);

  Future<Result<void>> call(int materialId, int quantity) {
    return repository.reserveMaterials(materialId, quantity);
  }
}
