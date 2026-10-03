import '../../../../core/error/result.dart';
import '../../../../core/utils/date_utils.dart' as app_utils;
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/repositories/order_repository.dart';

class GetWeekOrders {
  final OrderRepository repository;

  GetWeekOrders(this.repository);

  Future<Result<List<Order>>> call([DateTime? date]) {
    final target = date ?? DateTime.now();
    final start = app_utils.DateUtils.startOfWeek(target);
    final end = app_utils.DateUtils.endOfWeek(target);
    return repository.getOrdersForDateRange(start, end);
  }
}
