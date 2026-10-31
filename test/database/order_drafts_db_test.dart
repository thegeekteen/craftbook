import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart' show AppDatabase;
import 'package:craftbook/database/daos/channel_dao.dart';
import 'package:craftbook/database/daos/material_dao.dart';
import 'package:craftbook/database/daos/order_dao.dart';
import 'package:craftbook/database/daos/product_dao.dart';
import 'package:craftbook/features/orders/data/repositories/order_repository_impl.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_discount.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/usecases/calculate_order_profit.dart';
import 'package:craftbook/features/orders/domain/usecases/delete_order.dart';
import 'package:craftbook/features/orders/domain/usecases/return_order_stock.dart';
import 'package:craftbook/features/orders/domain/usecases/save_draft_order.dart';
import 'package:craftbook/features/orders/domain/usecases/update_order.dart';
import 'package:craftbook/features/products/data/repositories/channel_repository_impl.dart';
import 'package:craftbook/features/products/data/repositories/product_repository_impl.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/data/repositories/material_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Drafts against real repositories: saving one holds no stock, placing it
/// reserves, and no list that means "real orders" picks one up.
void main() {
  late AppDatabase db;
  late OrderRepositoryImpl orders;
  late MaterialRepositoryImpl materials;
  late ProductRepositoryImpl products;
  late SaveDraftOrder saveDraft;
  late UpdateOrder updateOrder;
  late DeleteOrder deleteOrder;
  late int shopee;
  late int yarn;
  late int tulip;
  late int pin;

  final day = DateTime(2026, 9, 1);
  final due = DateTime(2026, 9, 4);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    orders = OrderRepositoryImpl(OrderDao(db));
    materials = MaterialRepositoryImpl(MaterialDao(db), ProductDao(db));
    products = ProductRepositoryImpl(ProductDao(db));
    final channels = ChannelRepositoryImpl(ChannelDao(db));
    saveDraft = SaveDraftOrder(
      orderRepository: orders,
      productRepository: products,
      channelRepository: channels,
    );
    updateOrder = UpdateOrder(
      orderRepository: orders,
      productRepository: products,
      materialRepository: materials,
      calculateOrderProfit: CalculateOrderProfit(channels),
    );
    deleteOrder = DeleteOrder(
      orderRepository: orders,
      returnOrderStock: ReturnOrderStock(
          orderRepository: orders,
          materialRepository: materials,
          productRepository: products),
    );

    shopee = ok(await channels.createChannel(
        name: 'Shopee',
        commissionRate: 10,
        transactionFeeRate: 0,
        flatFee: 0,
        shippingPaidByUs: 0));
    yarn = ok(await materials.createMaterial(
      name: 'Yarn',
      packSize: 10,
      packPrice: 100,
      unitCost: 10,
      quantityOnHand: 100,
      alertLevel: 5,
    ));
    tulip = ok(await products.createProduct(name: 'Tulip', sellPrice: 450));
    ok(await products.saveBomItems(
        tulip, [BomItemInput(materialId: yarn, quantityRequired: 3)]));
    pin = ok(await products.createProduct(
      name: 'Pin',
      sellPrice: 100,
      isStandalone: true,
      initialQuantity: 10,
      initialUnitCost: 20,
    ));
  });

  tearDown(() => db.close());

  List<OrderItemInput> items() => [
        OrderItemInput(
            productId: tulip,
            productName: 'Tulip',
            quantity: 2,
            unitPrice: 450),
        OrderItemInput(
            productId: pin, productName: 'Pin', quantity: 3, unitPrice: 100),
      ];

  Future<double> promisedYarn() async =>
      ok(await materials.getMaterialById(yarn))!.quantityPromised;

  Future<double> promisedPins() async =>
      ok(await products.getProductById(pin))!.quantityPromised;

  group('SaveDraftOrder', () {
    test('keeps an unnamed order with no channel and holds nothing', () async {
      final id = ok(await saveDraft(
        customerName: '  ',
        orderDate: day,
        shipByDate: due,
        items: items(),
      ));

      final draft = ok(await orders.getOrderById(id))!;
      expect(draft.status, OrderStatus.draft);
      expect(draft.customerName, '');
      expect(draft.channelId, isNull);
      expect(draft.totalSales, 1200);
      expect(draft.channelFees, 0);
      expect(ok(await orders.getOrderMaterials(id)).single.plannedQuantity, 6);
      expect(await promisedYarn(), 0);
      expect(await promisedPins(), 0);
    });

    test('works money out with the channel once there is one', () async {
      final id = ok(await saveDraft(
        customerName: 'Maria',
        orderDate: day,
        shipByDate: due,
        channelId: shopee,
        items: items(),
        terms: const OrderTerms(discounts: [
          OrderDiscount(label: 'Promo', kind: DiscountKind.fixed, value: 200),
        ]),
      ));

      final draft = ok(await orders.getOrderById(id))!;
      expect(draft.channelId, shopee);
      expect(draft.discountTotal, 200);
      expect(draft.channelFees, closeTo(100, 0.001));
      expect(ok(await orders.getOrderDiscounts(id)).single.amount, 200);
    });

    test('a channel deleted meanwhile is simply left unset', () async {
      final id = ok(await saveDraft(
        customerName: 'Maria',
        orderDate: day,
        shipByDate: due,
        channelId: 999,
      ));
      expect(ok(await orders.getOrderById(id))!.channelId, isNull);
    });

    test('refuses an empty form', () async {
      final result = await saveDraft(
        customerName: '',
        note: '  ',
        orderDate: day,
        shipByDate: due,
        fieldValues: const {1: ' '},
      );
      expect(
          result, const Error<int>(ValidationFailure('Nothing to save yet')));
      expect(ok(await orders.getAllOrders()), isEmpty);
    });

    test('rewrites the same draft instead of making another', () async {
      final id = ok(await saveDraft(
          customerName: 'Maria', orderDate: day, shipByDate: due));
      final again = ok(await saveDraft(
        orderId: id,
        customerName: 'Maria Santos',
        orderDate: day,
        shipByDate: due,
        items: items(),
      ));

      expect(again, id);
      expect(ok(await orders.getAllOrders()), hasLength(1));
      expect(ok(await orders.getOrderById(id))!.customerName, 'Maria Santos');
      expect(ok(await orders.getOrderItems(id)), hasLength(2));
      expect(await promisedYarn(), 0);
    });

    test('will not turn a placed order back into a draft', () async {
      final id = ok(await saveDraft(
          customerName: 'Maria',
          orderDate: day,
          shipByDate: due,
          channelId: shopee,
          items: items()));
      ok(await updateOrder(
        orderId: id,
        customerName: 'Maria',
        orderDate: day,
        shipByDate: due,
        channelId: shopee,
        items: items(),
      ));

      final result = await saveDraft(
          orderId: id, customerName: 'Maria', orderDate: day, shipByDate: due);
      expect(result, isA<Error<int>>());
      expect(ok(await orders.getOrderById(id))!.status, OrderStatus.pending);
    });
  });

  group('placing a draft', () {
    Future<int> draft({bool paid = true}) async => ok(await saveDraft(
          customerName: 'Maria',
          orderDate: day,
          shipByDate: due,
          channelId: shopee,
          items: items(),
          terms: OrderTerms(isPaid: paid),
        ));

    test('makes it a pending order and reserves its stock once', () async {
      final id = await draft();

      ok(await updateOrder(
        orderId: id,
        customerName: 'Maria',
        orderDate: day,
        shipByDate: due,
        channelId: shopee,
        items: items(),
      ));

      expect(ok(await orders.getOrderById(id))!.status, OrderStatus.pending);
      expect(await promisedYarn(), 6);
      expect(await promisedPins(), 3);
    });

    test('a paid draft is stamped paid when it is placed', () async {
      final id = await draft();
      final before = ok(await orders.getOrderById(id))!.paidAt!;
      await Future<void>.delayed(const Duration(milliseconds: 1100));

      ok(await updateOrder(
        orderId: id,
        customerName: 'Maria',
        orderDate: day,
        shipByDate: due,
        channelId: shopee,
        items: items(),
        terms: const OrderTerms(isPaid: true),
      ));

      expect(
          ok(await orders.getOrderById(id))!.paidAt!.isAfter(before), isTrue);
    });

    test('needs a channel, a customer and an item', () async {
      final id = await draft();
      Future<Result<void>> place(
              {String name = 'Maria',
              int? channel,
              List<OrderItemInput>? lines}) =>
          updateOrder(
            orderId: id,
            customerName: name,
            orderDate: day,
            shipByDate: due,
            channelId: channel ?? shopee,
            items: lines ?? items(),
          );

      expect(await place(channel: 0), isA<Error<void>>());
      expect(await place(name: ' '), isA<Error<void>>());
      expect(await place(lines: const []), isA<Error<void>>());
      expect(ok(await orders.getOrderById(id))!.status, OrderStatus.draft);
      expect(await promisedYarn(), 0);
    });

    test('deleting a draft gives nothing back, because it took nothing',
        () async {
      final id = await draft();
      ok(await deleteOrder(id));
      expect(ok(await orders.getOrderById(id)), isNull);
      expect(ok(await materials.getMaterialById(yarn))!.quantityOnHand, 100);
      expect(await promisedYarn(), 0);
    });
  });

  test('drafts stay off the calendars, Today, receivables and sales', () async {
    final id = ok(await saveDraft(
      customerName: 'Maria',
      orderDate: day,
      shipByDate: due,
      channelId: shopee,
      items: items(),
      terms: const OrderTerms(isPaid: false),
    ));

    expect(ok(await orders.getOrdersForDate(day)), isEmpty);
    expect(
        ok(await orders.getOrdersForDateRange(
            day, due.add(const Duration(days: 1)))),
        isEmpty);
    expect(ok(await orders.getUnpaidOrders()), isEmpty);
    expect(ok(await products.getProductSales(tulip)), isEmpty);
    expect(ok(await orders.getOrderById(id))!.isAwaitingPayment, isFalse);
  });
}
