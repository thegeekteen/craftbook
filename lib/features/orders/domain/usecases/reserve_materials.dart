import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../stock/domain/repositories/material_repository.dart';

class ReserveMaterials {
  final MaterialRepository repository;

  ReserveMaterials(this.repository);

  Future<Either<Failure, void>> call(int materialId, int quantity) {
    return repository.reserveMaterials(materialId, quantity);
  }
}
