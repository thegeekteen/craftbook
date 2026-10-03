import '../../../../core/error/result.dart';
import '../entities/material.dart';
import '../repositories/material_repository.dart';

class GetMaterials {
  final MaterialRepository repository;

  GetMaterials(this.repository);

  Future<Result<List<Material>>> call({bool lowStockOnly = false}) async {
    if (lowStockOnly) {
      return repository.getLowStockMaterials();
    }
    return repository.getAllMaterials();
  }
}
