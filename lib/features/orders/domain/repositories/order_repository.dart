import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../entities/order_item.dart';
import '../entities/order_material.dart';
import '../entities/order_product.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<Order>>> getAllOrders();
  Future<Either<Failure, Order?>> getOrderById(int id);
  Future<Either<Failure, List<Order>>> getOrdersByStatus(OrderStatus status);
  Future<Either<Failure, List<Order>>> getOrdersForDate(DateTime date);
  Future<Either<Failure, List<Order>>> getOrdersForDateRange(DateTime start, DateTime end);
  Future<Either<Failure, List<OrderItem>>> getOrderItems(int orderId);
  Future<Either<Failure, List<OrderMaterial>>> getOrderMaterials(int orderId);
  Future<Either<Failure, List<OrderProduct>>> getOrderProducts(int orderId);
  Future<Either<Failure, int>> createOrder({
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
  Future<Either<Failure, void>> packOrder(int orderId);
  Future<Either<Failure, void>> shipOrder(int orderId);
  Future<Either<Failure, void>> adjustMaterialsUsed(int orderId, List<OrderMaterialInput> materials);
  Future<Either<Failure, void>> deleteOrder(int id);
}
