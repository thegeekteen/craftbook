import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../order_fields/domain/order_field_codec.dart';
import '../../../products/domain/entities/channel.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../entities/order.dart';
import '../entities/order_discount.dart';
import '../entities/order_item.dart';
import '../entities/order_money.dart';
import '../repositories/order_repository.dart';
import 'expand_order_items.dart';

/// Keeps a half-finished order as a draft: creates one, or rewrites the
/// draft [orderId].
///
/// Nothing has to be complete (no customer, channel or items is fine), but
/// there has to be something to keep. A draft reserves no stock; that
/// happens when it's placed through `UpdateOrder`. Its material lines and
/// money are still worked out so the draft reads like an order.
class SaveDraftOrder {
  final OrderRepository orderRepository;
  final ProductRepository productRepository;
  final ChannelRepository channelRepository;

  SaveDraftOrder({
    required this.orderRepository,
    required this.productRepository,
    required this.channelRepository,
  });

  Future<Result<int>> call({
    int? orderId,
    required String customerName,
    String? note,
    required DateTime orderDate,
    required DateTime shipByDate,
    int? channelId,
    List<OrderItemInput> items = const [],
    Map<int, String> fieldValues = const {},
    OrderTerms terms = const OrderTerms(),
  }) async {
    final name = customerName.trim();
    final trimmedNote = note?.trim();
    final cleanNote =
        trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote;
    final cleanFields = OrderFieldCodec.normalize(fieldValues);
    if (name.isEmpty &&
        cleanNote == null &&
        items.isEmpty &&
        cleanFields.isEmpty) {
      return const Error(ValidationFailure('Nothing to save yet'));
    }

    if (orderId != null) {
      final existing = await orderRepository.getOrderById(orderId);
      switch (existing) {
        case Error(:final failure):
          return Error(failure);
        case Success(:final value):
          if (value == null) {
            return const Error(NotFoundFailure('Order not found'));
          }
          if (value.status != OrderStatus.draft) {
            return const Error(
                ValidationFailure('Only drafts can be saved as a draft'));
          }
      }
    }

    // A channel deleted since the draft was started just leaves it unset.
    Channel? channel;
    if (channelId != null) {
      final found = await channelRepository.getChannelById(channelId);
      if (found case Error(:final failure)) return Error(failure);
      channel = (found as Success<Channel?>).value;
    }

    final expanded = await expandOrderItems(productRepository, items);
    final totalSales = items.fold<double>(0, (s, i) => s + i.subtotal);
    final money = OrderMoney.compute(
      itemsTotal: totalSales,
      discounts: terms.discounts,
      tax: terms.tax,
      channel: channel,
      materials: expanded.totalCost,
    );
    final savedTerms = terms.copyWith(discounts: money.discounts);

    if (orderId == null) {
      return orderRepository.createOrder(
        customerName: name,
        note: cleanNote,
        orderDate: orderDate,
        shipByDate: shipByDate,
        channelId: channel?.id,
        totalSales: totalSales,
        totalMaterialCost: expanded.totalCost,
        channelFees: money.fees,
        shippingCost: money.shipping,
        profit: money.profit,
        items: items,
        materials: expanded.materials,
        products: expanded.products,
        fieldValues: cleanFields,
        terms: savedTerms,
        discountTotal: money.discount,
        taxAmount: money.tax,
        status: OrderStatus.draft,
      );
    }

    final updated = await orderRepository.updateOrder(
      id: orderId,
      customerName: name,
      note: cleanNote,
      orderDate: orderDate,
      shipByDate: shipByDate,
      channelId: channel?.id,
      totalSales: totalSales,
      totalMaterialCost: expanded.totalCost,
      channelFees: money.fees,
      shippingCost: money.shipping,
      profit: money.profit,
      items: items,
      materials: expanded.materials,
      products: expanded.products,
      fieldValues: cleanFields,
      terms: savedTerms,
      discountTotal: money.discount,
      taxAmount: money.tax,
    );
    return switch (updated) {
      Error(:final failure) => Error(failure),
      Success() => Success(orderId),
    };
  }
}
