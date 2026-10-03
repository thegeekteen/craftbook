import 'package:craftbook/core/error/result.dart';

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

  Future<Result<void>> call(int channelId) async {
    final ordersResult = await orderRepository.getAllOrders();

    switch (ordersResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        final orders = value;
        final ordersUsingChannel =
            orders.where((o) => o.channelId == channelId).toList();

        if (ordersUsingChannel.isNotEmpty) {
          return Error(ValidationFailure(
            'Cannot delete channel: used by ${ordersUsingChannel.length} order(s)',
          ));
        }

        return channelRepository.deleteChannel(channelId);
    }
  }
}
