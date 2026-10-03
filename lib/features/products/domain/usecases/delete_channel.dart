import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../repositories/channel_repository.dart';

class DeleteChannel {
  final ChannelRepository channelRepository;
  final OrderRepository orderRepository;

  DeleteChannel({
    required this.channelRepository,
    required this.orderRepository,
  });

  Future<Either<Failure, void>> call(int channelId) async {
    final ordersResult = await orderRepository.getAllOrders();

    return ordersResult.fold(
      (failure) => Left(failure),
      (orders) async {
        final ordersUsingChannel =
            orders.where((o) => o.channelId == channelId).toList();

        if (ordersUsingChannel.isNotEmpty) {
          return Left(ValidationFailure(
            'Cannot delete channel: used by ${ordersUsingChannel.length} order(s)',
          ));
        }

        return channelRepository.deleteChannel(channelId);
      },
    );
  }
}
