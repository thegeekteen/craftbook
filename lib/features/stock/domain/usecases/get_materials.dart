import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/material.dart';
import '../repositories/material_repository.dart';

class GetMaterials {
  final MaterialRepository repository;

  GetMaterials(this.repository);

  Future<Either<Failure, List<Material>>> call({bool lowStockOnly = false}) async {
    if (lowStockOnly) {
      return repository.getLowStockMaterials();
    }
    return repository.getAllMaterials();
  }
}
