import '../../../../core/error/result.dart';
import '../../../order_fields/domain/entities/order_field_entry.dart';
import '../entities/order.dart';
import '../entities/order_discount.dart';
import '../entities/order_item.dart';
import '../entities/order_list_entry.dart';
import '../entities/order_material.dart';
import '../entities/order_product.dart';

abstract class OrderRepository {
  Future<Result<List<Order>>> getAllOrders();
  Future<Result<Order?>> getOrderById(int id);
  Future<Result<List<Order>>> getOrdersByStatus(OrderStatus status);

  /// Placed orders (drafts left out) by order date.
  Future<Result<List<Order>>> getOrdersForDate(DateTime date);

  /// Placed orders (drafts left out) by ship-by date.
  Future<Result<List<Order>>> getOrdersForDateRange(
      DateTime start, DateTime end);

  /// Pending or packed orders with a ship-by date before [end].
  Future<Result<List<Order>>> getOpenOrdersDueBefore(DateTime end);
  Future<Result<List<OrderItem>>> getOrderItems(int orderId);

  /// Product lines for each order id, in one round trip.
  Future<Result<Map<int, List<OrderLine>>>> getOrderLines(List<int> orderIds);
  Future<Result<List<OrderMaterial>>> getOrderMaterials(int orderId);
  Future<Result<List<OrderProduct>>> getOrderProducts(int orderId);

  /// Inserts the order with its lines. Stock reservations are the caller's
  /// job. A [OrderStatus.draft] may have no channel yet.
  Future<Result<int>> createOrder({
    required String customerName,
    String? note,
    required DateTime orderDate,
    required DateTime shipByDate,
    required int? channelId,
    required double totalSales,
    required double totalMaterialCost,
    required double channelFees,
    required double shippingCost,
    required double profit,
    required List<OrderItemInput> items,
    required List<OrderMaterialInput> materials,
    List<OrderProductInput> products,
    Map<int, String> fieldValues,

    /// Discounts (with their worked-out amounts), tax and paid status.
    OrderTerms terms,
    double discountTotal,
    double taxAmount,
    OrderStatus status,
  });

  /// Rewrites the order's own fields. When [items] is given the item,
  /// material and product lines are replaced with the given lists in the same
  /// transaction; stock reservations are the caller's job. [fieldValues],
  /// when given, is the order's complete set of custom field values.
  /// [terms], when given, replaces the discounts, tax and paid status; a
  /// newly paid order is stamped now, an already paid one keeps its date.
  /// [status], when given, moves the order there (placing a draft); a paid
  /// order is then stamped now, since the draft's date was never a payment.
  Future<Result<void>> updateOrder({
    required int id,
    required String customerName,
    String? note,
    required DateTime orderDate,
    required DateTime shipByDate,
    required int? channelId,
    required double totalSales,
    required double totalMaterialCost,
    required double channelFees,
    required double shippingCost,
    required double profit,
    List<OrderItemInput>? items,
    List<OrderMaterialInput>? materials,
    List<OrderProductInput>? products,
    Map<int, String>? fieldValues,
    OrderTerms? terms,
    double discountTotal,
    double taxAmount,
    OrderStatus? status,
  });

  /// The order's discount lines, in the order they were applied.
  Future<Result<List<OrderDiscount>>> getOrderDiscounts(int orderId);

  /// Unpaid orders that aren't drafts or cancelled, oldest first.
  Future<Result<List<Order>>> getUnpaidOrders();

  /// Marks the order paid (stamped now) or unpaid.
  Future<Result<void>> setOrderPaid(int orderId, bool paid);

  /// The order's custom field values, archived fields included, in field
  /// order.
  Future<Result<List<OrderFieldEntry>>> getOrderFieldValues(int orderId);

  /// Rewrites only the note, so it can change at any status — ticking a
  /// to-do on a shipped order must not go through the full order update.
  Future<Result<void>> updateOrderNote(int orderId, String? note);
  Future<Result<void>> packOrder(int orderId);
  Future<Result<void>> shipOrder(int orderId);
  Future<Result<void>> adjustMaterialsUsed(
      int orderId, List<OrderMaterialInput> materials);
  Future<Result<void>> cancelOrder(int orderId);

  /// Puts a cancelled order back to pending, clearing its packed and shipped
  /// dates. Stock is the caller's job.
  Future<Result<void>> restoreOrder(int orderId);
  Future<Result<void>> deleteOrder(int id);
}
