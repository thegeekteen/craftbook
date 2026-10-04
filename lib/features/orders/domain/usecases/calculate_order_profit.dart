import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/repositories/channel_repository.dart';

class CalculateOrderProfit {
  final ChannelRepository channelRepository;

  CalculateOrderProfit(this.channelRepository);

  Future<Result<OrderProfitBreakdown>> call({
    required double totalSales,
    required double totalMaterialCost,
    required int channelId,
    required double shippingCost,
  }) async {
    final channelResult = await channelRepository.getChannelById(channelId);

    switch (channelResult) {
      case Error(:final failure):
        return Error<OrderProfitBreakdown>(failure);
      case Success(:final value):
        final channel = value;
        if (channel == null) {
          return const Error<OrderProfitBreakdown>(
              NotFoundFailure('Channel not found'));
        }

        final fees = channel.calculateFees(totalSales);
        final totalShipping = shippingCost + channel.shippingPaidByUs;
        final profit = totalSales - totalMaterialCost - fees - totalShipping;

        return Success(OrderProfitBreakdown(
          totalSales: totalSales,
          totalMaterialCost: totalMaterialCost,
          channelFees: fees,
          shippingCost: totalShipping,
          profit: profit,
        ));
    }
  }
}

class OrderProfitBreakdown {
  final double totalSales;
  final double totalMaterialCost;
  final double channelFees;
  final double shippingCost;
  final double profit;

  const OrderProfitBreakdown({
    required this.totalSales,
    required this.totalMaterialCost,
    required this.channelFees,
    required this.shippingCost,
    required this.profit,
  });
}
