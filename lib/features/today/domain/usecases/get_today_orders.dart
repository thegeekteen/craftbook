import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/repositories/order_repository.dart';

class GetTodayOrders {
  final OrderRepository repository;

  GetTodayOrders(this.repository);

  Future<Either<Failure, List<Order>>> call([DateTime? date]) {
    return repository.getOrdersForDate(date ?? DateTime.now());
  }
}
