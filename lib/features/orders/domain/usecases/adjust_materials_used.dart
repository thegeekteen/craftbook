import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_material.dart';
import '../repositories/order_repository.dart';

class AdjustMaterialsUsed {
  final OrderRepository repository;

  AdjustMaterialsUsed(this.repository);

  Future<Either<Failure, void>> call(int orderId, List<OrderMaterialInput> materials) {
    return repository.adjustMaterialsUsed(orderId, materials);
  }
}
