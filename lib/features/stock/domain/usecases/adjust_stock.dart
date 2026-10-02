import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/material_repository.dart';

class AdjustStock {
  final MaterialRepository repository;

  AdjustStock(this.repository);

  Future<Either<Failure, void>> call(int materialId, int newQuantityOnHand) async {
    if (newQuantityOnHand < 0) {
      return Left(const ValidationFailure('Quantity cannot be negative'));
    }
    return repository.adjustStock(materialId, newQuantityOnHand);
  }
}
