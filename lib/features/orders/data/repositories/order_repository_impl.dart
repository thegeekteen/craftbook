import 'package:drift/drift.dart' hide Column;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/order_dao.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_material.dart';
import '../../domain/entities/order_product.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderDao dao;

  OrderRepositoryImpl(this.dao);

  // ── Queries ──────────────────────────────────────────────────────────

  @override
  Future<Result<List<Order>>> getAllOrders() async {
    try {
      final rows = await dao.getAllOrders();
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Order?>> getOrderById(int id) async {
    try {
      final row = await dao.getOrderById(id);
      return Success(row != null ? _toEntity(row) : null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getOrdersByStatus(
      OrderStatus status) async {
    try {
      final rows = await dao.getOrdersByStatus(_statusToString(status));
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getOrdersForDate(DateTime date) async {
    try {
      final rows = await dao.getOrdersForToday(date);
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getOrdersForDateRange(
      DateTime start, DateTime end) async {
    try {
      final rows = await dao.getOrdersForDateRange(start, end);
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<OrderItem>>> getOrderItems(
      int orderId) async {
    try {
      final rows = await dao.getOrderItems(orderId);
      final items = <OrderItem>[];
      for (final row in rows) {
        final productName = await dao.getProductName(row.productId);
        items.add(_itemToEntity(row, productName));
      }
      return Success(items);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<OrderMaterial>>> getOrderMaterials(
      int orderId) async {
    try {
      final rows = await dao.getOrderMaterials(orderId);
      final materials = <OrderMaterial>[];
      for (final row in rows) {
        final materialName = await dao.getMaterialName(row.materialId);
        materials.add(_materialToEntity(row, materialName));
      }
      return Success(materials);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<OrderProduct>>> getOrderProducts(
      int orderId) async {
    try {
      final rows = await dao.getOrderProducts(orderId);
      final products = <OrderProduct>[];
      for (final row in rows) {
        final productName = await dao.getProductName(row.productId);
        products.add(_productToEntity(row, productName));
      }
      return Success(products);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  // ── Commands ─────────────────────────────────────────────────────────

  @override
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
    List<OrderProductInput> products = const [],
  }) async {
    try {
      final orderId = await dao.createOrder(db.OrdersCompanion(
        customerName: Value(customerName),
        customerAddress: Value(customerAddress),
        note: Value(note),
        orderDate: Value(orderDate),
        shipByDate: Value(shipByDate),
        status: Value(_statusToString(OrderStatus.pending)),
        channelId: Value(channelId),
        totalSales: Value(totalSales),
        totalMaterialCost: Value(totalMaterialCost),
        channelFees: Value(channelFees),
        shippingCost: Value(shippingCost),
        profit: Value(profit),
      ));

      // Insert order items
      for (final item in items) {
        await dao.addOrderItem(db.OrderItemsCompanion(
          orderId: Value(orderId),
          productId: Value(item.productId),
          quantity: Value(item.quantity),
          unitPrice: Value(item.unitPrice),
          subtotal: Value(item.subtotal),
        ));
      }

      // Insert order materials (BOM products)
      for (final material in materials) {
        await dao.addOrderMaterial(db.OrderMaterialsCompanion(
          orderId: Value(orderId),
          materialId: Value(material.materialId),
          plannedQuantity: Value(material.plannedQuantity),
          actualQuantity: Value(material.actualQuantity),
          wasteQuantity: Value(material.wasteQuantity),
          wasteReason: Value(material.wasteReason),
          unitCost: Value(material.unitCost),
        ));
      }

      // Insert order products (standalone products)
      for (final product in products) {
        await dao.addOrderProduct(db.OrderProductsCompanion(
          orderId: Value(orderId),
          productId: Value(product.productId),
          quantity: Value(product.quantity),
          unitCost: Value(product.unitCost),
        ));
      }

      return Success(orderId);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> packOrder(int orderId) async {
    try {
      final now = DateTime.now();
      await (dao.update(dao.orders)..where((t) => t.id.equals(orderId)))
          .write(db.OrdersCompanion(
        status: Value(_statusToString(OrderStatus.packed)),
        packedAt: Value(now),
        updatedAt: Value(now),
      ));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> shipOrder(int orderId) async {
    try {
      final now = DateTime.now();
      await (dao.update(dao.orders)..where((t) => t.id.equals(orderId)))
          .write(db.OrdersCompanion(
        status: Value(_statusToString(OrderStatus.shipped)),
        shippedAt: Value(now),
        updatedAt: Value(now),
      ));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> adjustMaterialsUsed(
    int orderId,
    List<OrderMaterialInput> materials,
  ) async {
    try {
      final existingMaterials = await dao.getOrderMaterials(orderId);

      for (final input in materials) {
        final existing = existingMaterials
            .where((m) => m.materialId == input.materialId)
            .toList();

        if (existing.isNotEmpty) {
          // Update existing order_material row
          final row = existing.first;
          await dao.updateOrderMaterial(db.OrderMaterial(
            id: row.id,
            orderId: row.orderId,
            materialId: row.materialId,
            plannedQuantity: row.plannedQuantity,
            actualQuantity: input.actualQuantity,
            wasteQuantity: input.wasteQuantity,
            wasteReason: input.wasteReason,
            unitCost: input.unitCost,
            createdAt: row.createdAt,
          ));
        } else {
          // Insert new order_material row
          await dao.addOrderMaterial(db.OrderMaterialsCompanion(
            orderId: Value(orderId),
            materialId: Value(input.materialId),
            plannedQuantity: Value(input.plannedQuantity),
            actualQuantity: Value(input.actualQuantity),
            wasteQuantity: Value(input.wasteQuantity),
            wasteReason: Value(input.wasteReason),
            unitCost: Value(input.unitCost),
          ));
        }
      }

      // Recalculate total material cost (materials + standalone products) and profit
      final updatedMaterials = await dao.getOrderMaterials(orderId);
      final materialCost = updatedMaterials
          .fold<double>(0.0, (sum, m) => sum + m.actualQuantity * m.unitCost);
      final orderProducts = await dao.getOrderProducts(orderId);
      final productCost = orderProducts
          .fold<double>(0.0, (sum, p) => sum + p.quantity * p.unitCost);
      final totalCost = materialCost + productCost;

      final order = await dao.getOrderById(orderId);
      final newProfit = order != null
          ? order.totalSales - totalCost - order.channelFees - order.shippingCost
          : 0.0;

      final now = DateTime.now();
      await (dao.update(dao.orders)..where((t) => t.id.equals(orderId)))
          .write(db.OrdersCompanion(
        totalMaterialCost: Value(totalCost),
        profit: Value(newProfit),
        updatedAt: Value(now),
      ));

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteOrder(int id) async {
    try {
      await dao.deleteOrderItemsByOrderId(id);
      await dao.deleteOrderMaterialsByOrderId(id);
      await dao.deleteOrderProductsByOrderId(id);
      await dao.deleteStockMovementsByOrderId(id);
      await dao.deleteProductStockMovementsByOrderId(id);
      await dao.deleteOrder(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  // ── Mapping helpers ──────────────────────────────────────────────────

  Order _toEntity(db.Order row) => Order(
        id: row.id,
        customerName: row.customerName,
        customerAddress: row.customerAddress,
        note: row.note,
        orderDate: row.orderDate,
        shipByDate: row.shipByDate,
        packedAt: row.packedAt,
        shippedAt: row.shippedAt,
        status: _statusFromString(row.status),
        channelId: row.channelId,
        totalSales: row.totalSales,
        totalMaterialCost: row.totalMaterialCost,
        channelFees: row.channelFees,
        shippingCost: row.shippingCost,
        profit: row.profit,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  OrderItem _itemToEntity(db.OrderItem row, String productName) => OrderItem(
        id: row.id,
        orderId: row.orderId,
        productId: row.productId,
        productName: productName,
        quantity: row.quantity,
        unitPrice: row.unitPrice,
        subtotal: row.subtotal,
      );

  OrderMaterial _materialToEntity(
          db.OrderMaterial row, String materialName) =>
      OrderMaterial(
        id: row.id,
        orderId: row.orderId,
        materialId: row.materialId,
        materialName: materialName,
        plannedQuantity: row.plannedQuantity,
        actualQuantity: row.actualQuantity,
        wasteQuantity: row.wasteQuantity,
        wasteReason: row.wasteReason,
        unitCost: row.unitCost,
        createdAt: row.createdAt,
      );

  OrderProduct _productToEntity(db.OrderProduct row, String productName) =>
      OrderProduct(
        id: row.id,
        orderId: row.orderId,
        productId: row.productId,
        productName: productName,
        quantity: row.quantity,
        unitCost: row.unitCost,
      );

  // ── Status mapping ───────────────────────────────────────────────────

  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.packed:
        return 'packed';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'packed':
        return OrderStatus.packed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
