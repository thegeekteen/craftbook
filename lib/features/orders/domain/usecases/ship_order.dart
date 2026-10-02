import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/order_repository.dart';

class ShipOrder {
  final OrderRepository repository;

  ShipOrder(this.repository);

  Future<Either<Failure, void>> call(int orderId) {
    return repository.shipOrder(orderId);
  }
}
