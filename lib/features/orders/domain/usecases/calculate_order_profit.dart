import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../entities/order_discount.dart';
import '../entities/order_money.dart';

/// Looks the channel up and works an order's money out with [OrderMoney].
class CalculateOrderProfit {
  final ChannelRepository channelRepository;

  CalculateOrderProfit(this.channelRepository);

  /// [totalSales] is the items total before discounts. [shippingCost] is
  /// shipping on top of what the channel charges.
  Future<Result<OrderMoney>> call({
    required double totalSales,
    required double totalMaterialCost,
    required int channelId,
    required double shippingCost,
    List<OrderDiscount> discounts = const [],
    OrderTax? tax,
  }) async {
    final channelResult = await channelRepository.getChannelById(channelId);

    switch (channelResult) {
      case Error(:final failure):
        return Error<OrderMoney>(failure);
      case Success(:final value):
        if (value == null) {
          return const Error<OrderMoney>(NotFoundFailure('Channel not found'));
        }
        return Success(OrderMoney.compute(
          itemsTotal: totalSales,
          discounts: discounts,
          tax: tax,
          channel: value,
          materials: totalMaterialCost,
          extraShipping: shippingCost,
        ));
    }
  }
}
