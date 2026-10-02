import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/material.dart';
import '../entities/stock_movement.dart';
import '../repositories/material_repository.dart';

class GetMaterialDetail {
  final MaterialRepository repository;

  GetMaterialDetail(this.repository);

  Future<Either<Failure, MaterialDetailResult>> call(int materialId) async {
    final materialResult = await repository.getMaterialById(materialId);
    return materialResult.fold(
      (failure) => Left(failure),
      (material) async {
        if (material == null) {
          return Left(NotFoundFailure('Material not found'));
        }
        final movementsResult = await repository.getStockMovements(materialId);
        return movementsResult.fold(
          (failure) => Left(failure),
          (movements) => Right(MaterialDetailResult(
            material: material,
            movements: movements,
          )),
        );
      },
    );
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
