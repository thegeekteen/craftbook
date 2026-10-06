import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart' show AppDatabase;
import 'package:craftbook/database/daos/channel_dao.dart';
import 'package:craftbook/database/daos/earnings_dao.dart';
import 'package:craftbook/database/daos/material_dao.dart';
import 'package:craftbook/database/daos/order_dao.dart';
import 'package:craftbook/database/daos/product_dao.dart';
import 'package:craftbook/features/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:craftbook/features/earnings/domain/entities/report_filter.dart';
import 'package:craftbook/features/orders/data/repositories/order_repository_impl.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_discount.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/entities/order_money.dart';
import 'package:craftbook/features/orders/domain/usecases/calculate_order_profit.dart';
import 'package:craftbook/features/orders/domain/usecases/create_order.dart';
import 'package:craftbook/features/orders/domain/usecases/update_order.dart';
import 'package:craftbook/features/products/data/repositories/channel_repository_impl.dart';
import 'package:craftbook/features/products/data/repositories/product_repository_impl.dart';
import 'package:craftbook/features/stock/data/repositories/material_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Discounts, tax and paid status saved, edited and reported against a real
/// database.
void main() {
  late AppDatabase db;
  late OrderRepositoryImpl orders;
  late CalculateOrderProfit calculate;
  late CreateOrder createOrder;
  late UpdateOrder updateOrder;
  late EarningsRepositoryImpl earnings;
  late int shopee;
  late int walkIn;
  late int tulip;
  late int pin;

  final day = DateTime(2026, 9, 1);
  const loyal =
      OrderDiscount(label: 'Loyal', kind: DiscountKind.percent, value: 10);
  const vatIn = OrderTax(rate: 12, inclusive: true);
  const vatOn = OrderTax(rate: 12, inclusive: false);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    orders = OrderRepositoryImpl(OrderDao(db));
    final materials = MaterialRepositoryImpl(MaterialDao(db), ProductDao(db));
    final products = ProductRepositoryImpl(ProductDao(db));
    final channels = ChannelRepositoryImpl(ChannelDao(db));
    calculate = CalculateOrderProfit(channels);
    createOrder = CreateOrder(
        orderRepository: orders,
        productRepository: products,
        materialRepository: materials);
    updateOrder = UpdateOrder(
      orderRepository: orders,
      productRepository: products,
      materialRepository: materials,
      calculateOrderProfit: calculate,
    );
    earnings = EarningsRepositoryImpl(EarningsDao(db));

    shopee = ok(await channels.createChannel(
        name: 'Shopee',
        commissionRate: 10,
        transactionFeeRate: 0,
        flatFee: 0,
        shippingPaidByUs: 0));
    walkIn = ok(await channels.createChannel(
        name: 'Walk-in',
        commissionRate: 0,
        transactionFeeRate: 0,
        flatFee: 0,
        shippingPaidByUs: 0,
        paidByDefault: false));
    tulip = ok(await products.createProduct(name: 'Tulip', sellPrice: 500));
    pin = ok(await products.createProduct(
        name: 'Pin',
        sellPrice: 100,
        isStandalone: true,
        initialQuantity: 50,
        initialUnitCost: 20));
  });

  tearDown(() => db.close());

  OrderItemInput line(int productId, double qty, double price) =>
      OrderItemInput(
          productId: productId,
          productName: 'P',
          quantity: qty,
          unitPrice: price);

  /// Saves an order the way the new-order screen does.
  Future<int> create(
    List<OrderItemInput> items, {
    int? channelId,
    OrderTerms terms = const OrderTerms(),
  }) async {
    final sales = items.fold<double>(0, (s, i) => s + i.subtotal);
    final money = ok(await calculate(
      totalSales: sales,
      totalMaterialCost: 0,
      channelId: channelId ?? shopee,
      shippingCost: 0,
      discounts: terms.discounts,
      tax: terms.tax,
    ));
    return ok(await createOrder(
      customerName: 'Maria',
      orderDate: day,
      shipByDate: day,
      channelId: channelId ?? shopee,
      totalSales: sales,
      channelFees: money.fees,
      shippingCost: money.shipping,
      items: items,
      terms: terms.copyWith(discounts: money.discounts),
      discountTotal: money.discount,
      taxAmount: money.tax,
    ));
  }

  Future<Order> fetch(int id) async {
    final r = await orders.getOrderById(id);
    final v = ok(r);
    return v!;
  }

  group('saving', () {
    test('stores discount lines, tax and the profit that follows', () async {
      final id = await create([line(tulip, 2, 500)],
          terms: const OrderTerms(discounts: [loyal], tax: vatIn));

      final o = await fetch(id);
      expect(o.discountTotal, 100);
      expect(o.taxRate, 12);
      expect(o.taxInclusive, isTrue);
      expect(o.taxAmount, closeTo(96.43, 0.001)); // 900 × 12/112
      expect(o.channelFees, 90, reason: 'commission is on 900, not 1000');
      expect(o.profit, closeTo(900 - 96.43 - 90, 0.001));
      expect(OrderMoney.fromOrder(o).profit, closeTo(o.profit, 0.001));

      final lines = ok(await orders.getOrderDiscounts(id));
      expect(lines.single.label, 'Loyal');
      expect(lines.single.amount, 100);
    });

    test('an unpaid order has no paid date', () async {
      final id = await create([line(tulip, 1, 500)],
          channelId: walkIn, terms: const OrderTerms(isPaid: false));
      final o = await fetch(id);
      expect(o.isPaid, isFalse);
      expect(o.paidAt, isNull);
      expect(o.isAwaitingPayment, isTrue);
    });

    test('deleting the order deletes its discount lines', () async {
      final id = await create([line(tulip, 1, 500)],
          terms: const OrderTerms(discounts: [loyal]));
      ok(await orders.deleteOrder(id));
      expect(await db.select(db.orderDiscounts).get(), isEmpty);
    });
  });

  group('editing', () {
    test('keeps discounts and tax when the edit does not mention them',
        () async {
      final id = await create([line(tulip, 2, 500)],
          terms: const OrderTerms(discounts: [loyal], tax: vatIn));
      ok(await updateOrder(
        orderId: id,
        customerName: 'Maria L.',
        orderDate: day,
        shipByDate: day,
        channelId: shopee,
        items: [line(tulip, 3, 500)],
      ));
      final o = await fetch(id);
      expect(o.customerName, 'Maria L.');
      expect(o.discountTotal, 150, reason: '10% of the new 1500');
      expect(o.taxRate, 12);
      expect(ok(await orders.getOrderDiscounts(id)).single.amount, 150);
    });

    test('new terms replace the old and recompute fees', () async {
      final id = await create([line(tulip, 2, 500)],
          terms: const OrderTerms(discounts: [loyal]));
      ok(await updateOrder(
        orderId: id,
        customerName: 'Maria',
        orderDate: day,
        shipByDate: day,
        channelId: shopee,
        items: [line(tulip, 2, 500)],
        terms: const OrderTerms(tax: vatOn),
      ));
      final o = await fetch(id);
      expect(o.discountTotal, 0);
      expect(o.taxAmount, 120);
      expect(o.taxInclusive, isFalse);
      expect(o.channelFees, closeTo(112, 0.001), reason: '10% of 1120');
      expect(ok(await orders.getOrderDiscounts(id)), isEmpty);
    });

    test('a packed order can get a discount; its items stay put', () async {
      final id = await create([line(pin, 2, 100)]);
      ok(await orders.packOrder(id));
      ok(await updateOrder(
        orderId: id,
        customerName: 'Maria',
        orderDate: day,
        shipByDate: day,
        channelId: shopee,
        items: const [],
        terms: const OrderTerms(discounts: [
          OrderDiscount(label: 'Sorry', kind: DiscountKind.fixed, value: 30)
        ]),
      ));
      final o = await fetch(id);
      expect(o.discountTotal, 30);
      expect(o.channelFees, 17);
      expect(ok(await orders.getOrderItems(id)).single.quantity, 2);
    });

    test('an already paid order keeps its paid date', () async {
      final id = await create([line(tulip, 1, 500)]);
      final paidAt = (await fetch(id)).paidAt;
      ok(await updateOrder(
        orderId: id,
        customerName: 'Maria',
        orderDate: day,
        shipByDate: day,
        channelId: shopee,
        items: [line(tulip, 1, 500)],
        terms: const OrderTerms(),
      ));
      expect((await fetch(id)).paidAt, paidAt);
    });

    test('adjusting materials keeps discount and tax in profit', () async {
      final id = await create([line(tulip, 1, 500)],
          terms: const OrderTerms(discounts: [loyal], tax: vatIn));
      ok(await orders.adjustMaterialsUsed(id, const [
        OrderMaterialInput(
            materialId: 1,
            materialName: 'Yarn',
            plannedQuantity: 0,
            actualQuantity: 2,
            unitCost: 10),
      ]));
      final o = await fetch(id);
      expect(o.totalMaterialCost, 20);
      expect(o.profit, closeTo(OrderMoney.fromOrder(o).profit, 0.001));
      expect(o.profit, closeTo(450 - 48.21 - 45 - 20, 0.001));
    });
  });

  group('paid status', () {
    test('marking paid stamps the date, unpaid clears it', () async {
      final id = await create([line(tulip, 1, 500)],
          channelId: walkIn, terms: const OrderTerms(isPaid: false));
      ok(await orders.setOrderPaid(id, true));
      expect((await fetch(id)).paidAt, isNotNull);
      ok(await orders.setOrderPaid(id, false));
      final o = await fetch(id);
      expect((o.isPaid, o.paidAt), (false, null));
    });

    test('a missing order is reported', () async {
      expect(await orders.setOrderPaid(999, true), isA<Error<void>>());
    });
  });

  group('reports', () {
    final from = DateTime(2000);
    final to = DateTime(2100);

    Future<void> ship(int id) async {
      ok(await orders.packOrder(id));
      ok(await orders.shipOrder(id));
    }

    test('sum discounts, both kinds of tax, and unpaid money', () async {
      await ship(await create([line(tulip, 2, 500)],
          terms: const OrderTerms(discounts: [loyal], tax: vatIn)));
      await ship(await create([line(tulip, 1, 500)],
          channelId: walkIn,
          terms: const OrderTerms(tax: vatOn, isPaid: false)));

      final s = ok(await earnings.getEarningsSummary(from, to));
      expect(s.orderCount, 2);
      expect(s.totalSales, 1500);
      expect(s.totalDiscount, 100);
      expect(s.totalIncludedTax, closeTo(96.43, 0.001));
      expect(s.totalAddedTax, 60);
      expect(s.unpaidCount, 1);
      expect(s.unpaidTotal, 560);
      expect(s.totalProfit, closeTo(s.profit, 0.001));
      // 900 − 96.43 − 90 fees, plus 500 from the walk-in sale.
      expect(s.profit, closeTo(713.57 + 500, 0.001));
    });

    test('a filter narrows every part of the report', () async {
      await ship(await create([line(tulip, 1, 500)]));
      await ship(await create([line(pin, 1, 100)],
          channelId: walkIn, terms: const OrderTerms(isPaid: false)));

      const unpaid = ReportFilter(payment: PaymentFilter.unpaid);
      final s = ok(await earnings.getEarningsSummary(from, to, filter: unpaid));
      expect((s.orderCount, s.totalSales), (1, 100));
      final byProduct =
          ok(await earnings.getProductEarnings(from, to, filter: unpaid));
      expect(byProduct.map((p) => p.productId), [pin]);
      expect(
          ok(await earnings.getCompletedOrderProfits(from, to, filter: unpaid)),
          hasLength(1));

      final tulips = ReportFilter(productIds: {tulip}, channelIds: {shopee});
      expect(
          ok(await earnings.getEarningsSummary(from, to, filter: tulips))
              .totalSales,
          500);
      final big = const ReportFilter(minTotal: 200);
      expect(
          ok(await earnings.getEarningsSummary(from, to, filter: big))
              .orderCount,
          1);
    });
  });
}
