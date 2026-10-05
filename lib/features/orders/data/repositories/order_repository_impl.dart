import 'package:drift/drift.dart' hide Column;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/order_dao.dart';
import '../../../order_fields/data/repositories/order_field_repository_impl.dart';
import '../../../order_fields/domain/entities/order_field_entry.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_discount.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_list_entry.dart';
import '../../domain/entities/order_money.dart';
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
  Future<Result<List<Order>>> getOrdersByStatus(OrderStatus status) async {
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
  Future<Result<List<Order>>> getOpenOrdersDueBefore(DateTime end) async {
    try {
      final rows = await dao.getOpenOrdersDueBefore(end);
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<int, List<OrderLine>>>> getOrderLines(
      List<int> orderIds) async {
    try {
      final rows = await dao.getOrderLines(orderIds);
      final byOrder = <int, List<OrderLine>>{};
      for (final (orderId, name, qty) in rows) {
        byOrder
            .putIfAbsent(orderId, () => [])
            .add(OrderLine(productName: name, quantity: qty));
      }
      return Success(byOrder);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<OrderItem>>> getOrderItems(int orderId) async {
    try {
      final rows = await dao.getOrderItems(orderId);
      final items = <OrderItem>[];
      for (final row in rows) {
        final (productName, photo) =
            await dao.getProductNameAndPhoto(row.productId);
        items.add(_itemToEntity(row, productName, photo));
      }
      return Success(items);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<OrderMaterial>>> getOrderMaterials(int orderId) async {
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
  Future<Result<List<OrderProduct>>> getOrderProducts(int orderId) async {
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

  @override
  Future<Result<List<OrderFieldEntry>>> getOrderFieldValues(int orderId) async {
    try {
      final rows = await dao.getFieldValues(orderId);
      return Success([
        for (final (field, value) in rows)
          OrderFieldEntry(
            field: OrderFieldRepositoryImpl.toEntity(field),
            value: value,
          ),
      ]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  // ── Commands ─────────────────────────────────────────────────────────

  @override
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
    List<OrderProductInput> products = const [],
    Map<int, String> fieldValues = const {},
    OrderTerms terms = const OrderTerms(),
    double discountTotal = 0,
    double taxAmount = 0,
  }) async {
    try {
      final orderId = await dao.transaction(() => _insertOrder(
            terms: terms,
            discountTotal: discountTotal,
            taxAmount: taxAmount,
            customerName: customerName,
            note: note,
            orderDate: orderDate,
            shipByDate: shipByDate,
            channelId: channelId,
            totalSales: totalSales,
            totalMaterialCost: totalMaterialCost,
            channelFees: channelFees,
            shippingCost: shippingCost,
            profit: profit,
            items: items,
            materials: materials,
            products: products,
            fieldValues: fieldValues,
          ));
      return Success(orderId);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  Future<int> _insertOrder({
    required OrderTerms terms,
    required double discountTotal,
    required double taxAmount,
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
    required List<OrderProductInput> products,
    required Map<int, String> fieldValues,
  }) async {
    final orderId = await dao.createOrder(db.OrdersCompanion(
      customerName: Value(customerName),
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
      discountTotal: Value(discountTotal),
      taxRate: Value(terms.tax?.rate),
      taxAmount: Value(taxAmount),
      taxInclusive: Value(terms.tax?.inclusive ?? true),
      isPaid: Value(terms.isPaid),
      paidAt: Value(terms.isPaid ? DateTime.now() : null),
    ));
    await dao.replaceOrderDiscounts(orderId, _discountRows(terms.discounts));

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

    await dao.replaceFieldValues(orderId, fieldValues);
    return orderId;
  }

  @override
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
    OrderTerms? terms,
    double discountTotal = 0,
    double taxAmount = 0,
  }) async {
    try {
      await dao.transaction(() async {
        if (terms != null) {
          final existing = await dao.getOrderById(id);
          await (dao.update(dao.orders)..where((t) => t.id.equals(id)))
              .write(db.OrdersCompanion(
            discountTotal: Value(discountTotal),
            taxRate: Value(terms.tax?.rate),
            taxAmount: Value(taxAmount),
            taxInclusive: Value(terms.tax?.inclusive ?? true),
            isPaid: Value(terms.isPaid),
            paidAt: Value(
                terms.isPaid ? (existing?.paidAt ?? DateTime.now()) : null),
          ));
          await dao.replaceOrderDiscounts(id, _discountRows(terms.discounts));
        }
        await (dao.update(dao.orders)..where((t) => t.id.equals(id)))
            .write(db.OrdersCompanion(
          customerName: Value(customerName),
          note: Value(note),
          orderDate: Value(orderDate),
          shipByDate: Value(shipByDate),
          channelId: Value(channelId),
          totalSales: Value(totalSales),
          totalMaterialCost: Value(totalMaterialCost),
          channelFees: Value(channelFees),
          shippingCost: Value(shippingCost),
          profit: Value(profit),
          updatedAt: Value(DateTime.now()),
        ));
        if (fieldValues != null) {
          await dao.replaceFieldValues(id, fieldValues);
        }

        if (items == null) return;
        await dao.deleteOrderItemsByOrderId(id);
        await dao.deleteOrderMaterialsByOrderId(id);
        await dao.deleteOrderProductsByOrderId(id);
        for (final item in items) {
          await dao.addOrderItem(db.OrderItemsCompanion(
            orderId: Value(id),
            productId: Value(item.productId),
            quantity: Value(item.quantity),
            unitPrice: Value(item.unitPrice),
            subtotal: Value(item.subtotal),
          ));
        }
        for (final material in materials ?? const <OrderMaterialInput>[]) {
          await dao.addOrderMaterial(db.OrderMaterialsCompanion(
            orderId: Value(id),
            materialId: Value(material.materialId),
            plannedQuantity: Value(material.plannedQuantity),
            actualQuantity: Value(material.actualQuantity),
            wasteQuantity: Value(material.wasteQuantity),
            wasteReason: Value(material.wasteReason),
            unitCost: Value(material.unitCost),
          ));
        }
        for (final product in products ?? const <OrderProductInput>[]) {
          await dao.addOrderProduct(db.OrderProductsCompanion(
            orderId: Value(id),
            productId: Value(product.productId),
            quantity: Value(product.quantity),
            unitCost: Value(product.unitCost),
          ));
        }
      });
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<OrderDiscount>>> getOrderDiscounts(int orderId) async {
    try {
      final rows = await dao.getOrderDiscounts(orderId);
      return Success([
        for (final r in rows)
          OrderDiscount(
            label: r.label,
            kind: DiscountKind.fromName(r.kind),
            value: r.value,
            amount: r.amount,
          ),
      ]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getUnpaidOrders() async {
    try {
      final rows = await dao.getUnpaidOrders();
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setOrderPaid(int orderId, bool paid) async {
    try {
      final now = DateTime.now();
      final updated = await (dao.update(dao.orders)
            ..where((t) => t.id.equals(orderId)))
          .write(db.OrdersCompanion(
        isPaid: Value(paid),
        paidAt: Value(paid ? now : null),
        updatedAt: Value(now),
      ));
      if (updated == 0) return const Error(NotFoundFailure('Order not found'));
      return const Success(null);
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
  Future<Result<void>> updateOrderNote(int orderId, String? note) async {
    try {
      final updated = await (dao.update(dao.orders)
            ..where((t) => t.id.equals(orderId)))
          .write(db.OrdersCompanion(
        note: Value(note),
        updatedAt: Value(DateTime.now()),
      ));
      if (updated == 0) return const Error(NotFoundFailure('Order not found'));
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
      final materialCost = updatedMaterials.fold<double>(
          0.0, (sum, m) => sum + m.actualQuantity * m.unitCost);
      final orderProducts = await dao.getOrderProducts(orderId);
      final productCost = orderProducts.fold<double>(
          0.0, (sum, p) => sum + p.quantity * p.unitCost);
      final totalCost = materialCost + productCost;

      final order = await dao.getOrderById(orderId);
      final newProfit = order != null
          ? OrderMoney.fromOrder(_toEntity(order))
              .withMaterials(totalCost)
              .profit
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
  Future<Result<void>> cancelOrder(int orderId) async {
    try {
      final updated = await (dao.update(dao.orders)
            ..where((t) => t.id.equals(orderId)))
          .write(db.OrdersCompanion(
        status: Value(_statusToString(OrderStatus.cancelled)),
        updatedAt: Value(DateTime.now()),
      ));
      if (updated == 0) return const Error(NotFoundFailure('Order not found'));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> restoreOrder(int orderId) async {
    try {
      final updated = await (dao.update(dao.orders)
            ..where((t) => t.id.equals(orderId)))
          .write(db.OrdersCompanion(
        status: Value(_statusToString(OrderStatus.pending)),
        packedAt: const Value(null),
        shippedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ));
      if (updated == 0) return const Error(NotFoundFailure('Order not found'));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteOrder(int id) async {
    try {
      await dao.transaction(() async {
        await dao.deleteOrderItemsByOrderId(id);
        await dao.deleteOrderMaterialsByOrderId(id);
        await dao.deleteOrderProductsByOrderId(id);
        await dao.deleteStockMovementsByOrderId(id);
        await dao.deleteProductStockMovementsByOrderId(id);
        await dao.deleteFieldValuesByOrderId(id);
        await dao.deleteDiscountsByOrderId(id);
        await dao.deleteOrder(id);
      });
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  // ── Mapping helpers ──────────────────────────────────────────────────

  Order _toEntity(db.Order row) => toEntity(row);

  /// Shared with the reports repository, which reads the same rows.
  static Order toEntity(db.Order row) => Order(
        id: row.id,
        customerName: row.customerName,
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
        discountTotal: row.discountTotal,
        taxRate: row.taxRate,
        taxAmount: row.taxAmount,
        taxInclusive: row.taxInclusive,
        isPaid: row.isPaid,
        paidAt: row.paidAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  static List<db.OrderDiscountsCompanion> _discountRows(
          List<OrderDiscount> discounts) =>
      [
        for (final d in discounts)
          db.OrderDiscountsCompanion.insert(
            orderId: 0, // set by the DAO
            label: d.label,
            kind: d.kind.name,
            value: d.value,
            amount: d.amount,
          ),
      ];

  OrderItem _itemToEntity(
    db.OrderItem row,
    String productName,
    Uint8List? productPhoto,
  ) =>
      OrderItem(
        id: row.id,
        orderId: row.orderId,
        productId: row.productId,
        productName: productName,
        productPhoto: productPhoto,
        quantity: row.quantity,
        unitPrice: row.unitPrice,
        subtotal: row.subtotal,
      );

  OrderMaterial _materialToEntity(db.OrderMaterial row, String materialName) =>
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
