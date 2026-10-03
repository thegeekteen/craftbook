import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../repositories/material_repository.dart';

class AdjustStock {
  final MaterialRepository repository;

  AdjustStock(this.repository);

  Future<Result<void>> call(int materialId, int newQuantityOnHand) async {
    if (newQuantityOnHand < 0) {
      return Error(const ValidationFailure('Quantity cannot be negative'));
    }
    return repository.adjustStock(materialId, newQuantityOnHand);
  }
}
