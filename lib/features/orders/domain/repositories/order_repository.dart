import '../../../../core/error/result.dart';
import '../../../order_fields/domain/entities/order_field_entry.dart';
import '../entities/order.dart';
import '../entities/order_item.dart';
import '../entities/order_list_entry.dart';
import '../entities/order_material.dart';
import '../entities/order_product.dart';

abstract class OrderRepository {
  Future<Result<List<Order>>> getAllOrders();
  Future<Result<Order?>> getOrderById(int id);
  Future<Result<List<Order>>> getOrdersByStatus(OrderStatus status);
  Future<Result<List<Order>>> getOrdersForDate(DateTime date);
  Future<Result<List<Order>>> getOrdersForDateRange(
      DateTime start, DateTime end);

  /// Pending or packed orders with a ship-by date before [end].
  Future<Result<List<Order>>> getOpenOrdersDueBefore(DateTime end);
  Future<Result<List<OrderItem>>> getOrderItems(int orderId);

  /// Product lines for each order id, in one round trip.
  Future<Result<Map<int, List<OrderLine>>>> getOrderLines(List<int> orderIds);
  Future<Result<List<OrderMaterial>>> getOrderMaterials(int orderId);
  Future<Result<List<OrderProduct>>> getOrderProducts(int orderId);
  Future<Result<int>> createOrder({
    required String customerName,
    String? note,
    required DateTime orderDate,
    required DateTime shipByDate,
    required int channelId,
    required double totalSales,
    required double totalMaterialCost,
    required double channelFees,
    required double shippingCost,
    required double profit,
    required List<OrderItemInput> items,
    required List<OrderMaterialInput> materials,
    List<OrderProductInput> products,
    Map<int, String> fieldValues,
  });

  /// Rewrites the order's own fields. When [items] is given the item,
  /// material and product lines are replaced with the given lists in the same
  /// transaction; stock reservations are the caller's job. [fieldValues],
  /// when given, is the order's complete set of custom field values.
  Future<Result<void>> updateOrder({
    required int id,
    required String customerName,
    String? note,
    required DateTime orderDate,
    required DateTime shipByDate,
    required int channelId,
    required double totalSales,
    required double totalMaterialCost,
    required double channelFees,
    required double shippingCost,
    required double profit,
    List<OrderItemInput>? items,
    List<OrderMaterialInput>? materials,
    List<OrderProductInput>? products,
    Map<int, String>? fieldValues,
  });

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
  Future<Result<void>> deleteOrder(int id);
}
