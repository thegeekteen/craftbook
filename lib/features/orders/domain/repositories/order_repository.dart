import '../../../../core/error/result.dart';
import '../entities/order.dart';
import '../entities/order_item.dart';
import '../entities/order_material.dart';
import '../entities/order_product.dart';

abstract class OrderRepository {
  Future<Result<List<Order>>> getAllOrders();
  Future<Result<Order?>> getOrderById(int id);
  Future<Result<List<Order>>> getOrdersByStatus(OrderStatus status);
  Future<Result<List<Order>>> getOrdersForDate(DateTime date);
  Future<Result<List<Order>>> getOrdersForDateRange(DateTime start, DateTime end);
  Future<Result<List<OrderItem>>> getOrderItems(int orderId);
  Future<Result<List<OrderMaterial>>> getOrderMaterials(int orderId);
  Future<Result<List<OrderProduct>>> getOrderProducts(int orderId);
  Future<Result<int>> createOrder({
    required String customerName,
    required String customerAddress,
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
  });
  Future<Result<void>> packOrder(int orderId);
  Future<Result<void>> shipOrder(int orderId);
  Future<Result<void>> adjustMaterialsUsed(int orderId, List<OrderMaterialInput> materials);
  Future<Result<void>> deleteOrder(int id);
}
