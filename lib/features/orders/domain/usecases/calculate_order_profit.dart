import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/channel.dart';
import '../../../products/domain/repositories/channel_repository.dart';

class CalculateOrderProfit {
  final ChannelRepository channelRepository;

  CalculateOrderProfit(this.channelRepository);

  Future<Either<Failure, OrderProfitBreakdown>> call({
    required double totalSales,
    required double totalMaterialCost,
    required int channelId,
    required double shippingCost,
  }) async {
    final channelResult = await channelRepository.getChannelById(channelId);

    return channelResult.fold(
      (failure) => Left(failure),
      (channel) {
        if (channel == null) {
          return Left(NotFoundFailure('Channel not found'));
        }

        final fees = channel.calculateFees(totalSales);
        final totalShipping = shippingCost + channel.shippingPaidByUs;
        final profit = totalSales - totalMaterialCost - fees - totalShipping;

        return Right(OrderProfitBreakdown(
          totalSales: totalSales,
          totalMaterialCost: totalMaterialCost,
          channelFees: fees,
          shippingCost: totalShipping,
          profit: profit,
        ));
      },
    );
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
