import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/quantity.dart';
import '../../../order_fields/domain/order_field_codec.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../entities/order.dart';
import '../entities/order_discount.dart';
import '../entities/order_item.dart';
import '../entities/order_money.dart';
import '../entities/order_material.dart';
import '../entities/order_product.dart';
import '../repositories/order_repository.dart';
import 'calculate_order_profit.dart';
import 'expand_order_items.dart';

/// Edits an existing order. What can change depends on how far it got:
///
/// * **pending**: everything. Reservations are released and re-made for the
///   new items.
/// * **packed**: customer, order fields, note, dates, channel, discounts,
///   tax and paid. Items are locked because their stock has already been
///   deducted.
///
/// Fees, discounts and tax are worked out again for pending and packed
/// orders, since the channel or the items may have changed.
/// * **shipped**: the note only.
/// * **cancelled**: nothing.
class UpdateOrder {
  final OrderRepository orderRepository;
  final ProductRepository productRepository;
  final MaterialRepository materialRepository;
  final CalculateOrderProfit calculateOrderProfit;

  UpdateOrder({
    required this.orderRepository,
    required this.productRepository,
    required this.materialRepository,
    required this.calculateOrderProfit,
  });

  Future<Result<void>> call({
    required int orderId,
    required String customerName,
    String? note,
    required DateTime orderDate,
    required DateTime shipByDate,
    required int channelId,
    required List<OrderItemInput> items,

    /// The order's complete set of custom field values by field id; blanks
    /// clear the field.
    Map<int, String> fieldValues = const {},

    /// Discounts, tax and paid status; null keeps the order's own.
    OrderTerms? terms,
  }) async {
    final orderResult = await orderRepository.getOrderById(orderId);
    final Order? order;
    switch (orderResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        order = value;
    }
    if (order == null) return const Error(NotFoundFailure('Order not found'));

    final trimmedNote = note?.trim();
    final cleanNote =
        trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote;
    final cleanFields = OrderFieldCodec.normalize(fieldValues);

    switch (order.status) {
      case OrderStatus.cancelled:
        return const Error(
            ValidationFailure('Cancelled orders cannot be edited'));
      case OrderStatus.shipped:
        // Money and dates are history by now; only the note may change.
        return orderRepository.updateOrder(
          id: orderId,
          customerName: order.customerName,
          note: cleanNote,
          orderDate: order.orderDate,
          shipByDate: order.shipByDate,
          channelId: order.channelId ?? channelId,
          totalSales: order.totalSales,
          totalMaterialCost: order.totalMaterialCost,
          channelFees: order.channelFees,
          shippingCost: order.shippingCost,
          profit: order.profit,
        );
      case OrderStatus.packed:
      case OrderStatus.pending:
        break;
    }

    if (customerName.trim().isEmpty) {
      return const Error(ValidationFailure('Customer name is required'));
    }
    if (shipByDate.isBefore(orderDate)) {
      return const Error(
          ValidationFailure('Ship-by date cannot be before the order date'));
    }

    final OrderTerms newTerms;
    if (terms != null) {
      newTerms = terms;
    } else {
      final current = await orderRepository.getOrderDiscounts(orderId);
      if (current case Error(:final failure)) return Error(failure);
      final rate = order.taxRate;
      newTerms = OrderTerms(
        discounts: (current as Success<List<OrderDiscount>>).value,
        tax: rate == null
            ? null
            : OrderTax(rate: rate, inclusive: order.taxInclusive),
        isPaid: order.isPaid,
      );
    }

    if (order.status == OrderStatus.packed) {
      return _updatePacked(order, customerName, cleanFields, cleanNote,
          orderDate, shipByDate, channelId, newTerms);
    }
    return _updatePending(order, customerName, cleanFields, cleanNote,
        orderDate, shipByDate, channelId, items, newTerms);
  }

  Future<Result<void>> _updatePacked(
    Order order,
    String customerName,
    Map<int, String> fieldValues,
    String? note,
    DateTime orderDate,
    DateTime shipByDate,
    int channelId,
    OrderTerms terms,
  ) async {
    final breakdown = await calculateOrderProfit(
      totalSales: order.totalSales,
      totalMaterialCost: order.totalMaterialCost,
      channelId: channelId,
      shippingCost: 0,
      discounts: terms.discounts,
      tax: terms.tax,
    );
    switch (breakdown) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        return orderRepository.updateOrder(
          id: order.id!,
          customerName: customerName.trim(),
          fieldValues: fieldValues,
          note: note,
          orderDate: orderDate,
          shipByDate: shipByDate,
          channelId: channelId,
          totalSales: order.totalSales,
          totalMaterialCost: order.totalMaterialCost,
          channelFees: value.fees,
          shippingCost: value.shipping,
          profit: value.profit,
          terms: terms.copyWith(discounts: value.discounts),
          discountTotal: value.discount,
          taxAmount: value.tax,
        );
    }
  }

  Future<Result<void>> _updatePending(
    Order order,
    String customerName,
    Map<int, String> fieldValues,
    String? note,
    DateTime orderDate,
    DateTime shipByDate,
    int channelId,
    List<OrderItemInput> items,
    OrderTerms terms,
  ) async {
    if (items.isEmpty) {
      return const Error(ValidationFailure('At least one item is required'));
    }
    final orderId = order.id!;

    final oldMaterialsResult = await orderRepository.getOrderMaterials(orderId);
    final oldProductsResult = await orderRepository.getOrderProducts(orderId);
    if (oldMaterialsResult case Error(:final failure)) return Error(failure);
    if (oldProductsResult case Error(:final failure)) return Error(failure);
    final oldMaterials =
        (oldMaterialsResult as Success<List<OrderMaterial>>).value;
    final oldProducts =
        (oldProductsResult as Success<List<OrderProduct>>).value;

    final expanded = await expandOrderItems(productRepository, items);
    // A line that needs the same amount as before keeps its recorded waste
    // and cost snapshot instead of being reset to the plan.
    final materials = [
      for (final m in expanded.materials)
        _keepIfUnchanged(m, oldMaterials) ?? m,
    ];
    final products = [
      for (final p in expanded.products)
        _keepProductIfUnchanged(p, oldProducts) ?? p,
    ];
    final materialCost = ExpandedOrder(materials, products).totalCost;

    final totalSales = items.fold<double>(0, (s, i) => s + i.subtotal);
    final breakdown = await calculateOrderProfit(
      totalSales: totalSales,
      totalMaterialCost: materialCost,
      channelId: channelId,
      shippingCost: 0,
      discounts: terms.discounts,
      tax: terms.tax,
    );
    final OrderMoney figures;
    switch (breakdown) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        figures = value;
    }

    final saved = await orderRepository.updateOrder(
      id: orderId,
      customerName: customerName.trim(),
      fieldValues: fieldValues,
      note: note,
      orderDate: orderDate,
      shipByDate: shipByDate,
      channelId: channelId,
      totalSales: totalSales,
      totalMaterialCost: materialCost,
      channelFees: figures.fees,
      shippingCost: figures.shipping,
      profit: figures.profit,
      terms: terms.copyWith(discounts: figures.discounts),
      discountTotal: figures.discount,
      taxAmount: figures.tax,
      items: items,
      materials: materials,
      products: products,
    );
    if (saved case Error()) return saved;

    // Rows are replaced; now move the reservations from the old plan to the new.
    for (final m in oldMaterials) {
      await materialRepository.releaseReservedMaterials(
          m.materialId, m.plannedQuantity);
    }
    for (final p in oldProducts) {
      await productRepository.releaseReservedProductStock(
          p.productId, p.quantity);
    }
    for (final m in materials) {
      await materialRepository.reserveMaterials(
          m.materialId, m.plannedQuantity);
    }
    for (final p in products) {
      await productRepository.reserveProductStock(p.productId, p.quantity);
    }
    return const Success(null);
  }

  OrderMaterialInput? _keepIfUnchanged(
      OrderMaterialInput fresh, List<OrderMaterial> old) {
    final match = old
        .where((o) =>
            o.materialId == fresh.materialId &&
            sameQty(o.plannedQuantity, fresh.plannedQuantity))
        .firstOrNull;
    if (match == null) return null;
    return OrderMaterialInput(
      materialId: match.materialId,
      materialName: match.materialName,
      plannedQuantity: match.plannedQuantity,
      actualQuantity: match.actualQuantity,
      wasteQuantity: match.wasteQuantity,
      wasteReason: match.wasteReason,
      unitCost: match.unitCost,
    );
  }

  OrderProductInput? _keepProductIfUnchanged(
      OrderProductInput fresh, List<OrderProduct> old) {
    final match = old
        .where((o) =>
            o.productId == fresh.productId &&
            sameQty(o.quantity, fresh.quantity))
        .firstOrNull;
    if (match == null) return null;
    return OrderProductInput(
      productId: match.productId,
      productName: fresh.productName,
      quantity: match.quantity,
      unitCost: match.unitCost,
    );
  }
}
