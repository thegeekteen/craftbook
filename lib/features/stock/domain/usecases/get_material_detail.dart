import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/material.dart';
import '../entities/stock_movement.dart';
import '../repositories/material_repository.dart';

class GetMaterialDetail {
  final MaterialRepository repository;

  GetMaterialDetail(this.repository);

  Future<Result<MaterialDetailResult>> call(int materialId) async {
    final materialResult = await repository.getMaterialById(materialId);
    switch (materialResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(value: final material):
        if (material == null) {
          return const Error(NotFoundFailure('Material not found'));
        }
        final movementsResult = await repository.getStockMovements(materialId);
        switch (movementsResult) {
          case Error(:final failure):
            return Error(failure);
          case Success(value: final movements):
            return Success(MaterialDetailResult(
              material: material,
              movements: movements,
            ));
        }
    }
  }
}

class MaterialDetailResult {
  final Material material;
  final List<StockMovement> movements;

  const MaterialDetailResult({
    required this.material,
    required this.movements,
  });
}
