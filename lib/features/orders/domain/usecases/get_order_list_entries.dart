import '../../../../core/error/result.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../entities/order.dart';
import '../entities/order_list_entry.dart';
import '../repositories/order_repository.dart';

/// Decorates orders with their channel name and product lines so list
/// screens can show "2× Tulip bouquet · Shopee" without extra lookups.
class GetOrderListEntries {
  final OrderRepository orderRepository;
  final ChannelRepository channelRepository;

  GetOrderListEntries({
    required this.orderRepository,
    required this.channelRepository,
  });

  Future<Result<List<OrderListEntry>>> call(List<Order> orders) async {
    if (orders.isEmpty) return const Success([]);

    final ids = [
      for (final o in orders)
        if (o.id != null) o.id!
    ];
    final linesResult = await orderRepository.getOrderLines(ids);
    final Map<int, List<OrderLine>> lines;
    switch (linesResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        lines = value;
    }

    final channelsResult = await channelRepository.getAllChannels();
    final channelNames = <int, String>{};
    switch (channelsResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        for (final c in value) {
          if (c.id != null) channelNames[c.id!] = c.name;
        }
    }

    return Success([
      for (final o in orders)
        OrderListEntry(
          order: o,
          channelName: o.channelId == null ? null : channelNames[o.channelId],
          lines: lines[o.id] ?? const [],
        ),
    ]);
  }
}
