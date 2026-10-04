import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/database/daos/channel_dao.dart';
import 'package:craftbook/database/daos/material_dao.dart';
import 'package:craftbook/database/daos/order_dao.dart';
import 'package:craftbook/database/daos/product_dao.dart';
import 'package:craftbook/features/orders/data/repositories/order_repository_impl.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/usecases/calculate_order_profit.dart';
import 'package:craftbook/features/orders/domain/usecases/create_order.dart';
import 'package:craftbook/features/orders/domain/usecases/pack_order.dart';
import 'package:craftbook/features/orders/domain/usecases/update_order.dart';
import 'package:craftbook/features/products/data/repositories/channel_repository_impl.dart';
import 'package:craftbook/features/products/data/repositories/product_repository_impl.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/data/repositories/material_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/sqlite.dart';

T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// UpdateOrder against real repositories, so reservations are checked for
/// real rather than through mocks.
void main() {
  setUpAll(useHostSqlite);

  late AppDatabase db;
  late OrderRepositoryImpl orders;
  late MaterialRepositoryImpl materials;
  late ProductRepositoryImpl products;
  late CreateOrder createOrder;
  late UpdateOrder updateOrder;
  late PackOrder packOrder;
  late int channelA;
  late int channelB;
  late int yarn;
  late int tulip;
  late int rose;
  late int pin;

  final day = DateTime(2026, 9, 1);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    orders = OrderRepositoryImpl(OrderDao(db));
    materials = MaterialRepositoryImpl(MaterialDao(db), ProductDao(db));
    products = ProductRepositoryImpl(ProductDao(db));
    final channels = ChannelRepositoryImpl(ChannelDao(db));
    final profit = CalculateOrderProfit(channels);
    createOrder = CreateOrder(
        orderRepository: orders,
        productRepository: products,
        materialRepository: materials);
    updateOrder = UpdateOrder(
      orderRepository: orders,
      productRepository: products,
      materialRepository: materials,
      calculateOrderProfit: profit,
    );
    packOrder = PackOrder(
        orderRepository: orders,
        materialRepository: materials,
        productRepository: products);

    channelA = ok(await channels.createChannel(
        name: 'Shopee',
        commissionRate: 10,
        transactionFeeRate: 0,
        flatFee: 0,
        shippingPaidByUs: 0));
    channelB = ok(await channels.createChannel(
        name: 'Direct',
        commissionRate: 0,
        transactionFeeRate: 0,
        flatFee: 0,
        shippingPaidByUs: 20));

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
    rose = ok(await products.createProduct(name: 'Rose', sellPrice: 300));
    ok(await products.saveBomItems(
        rose, [BomItemInput(materialId: yarn, quantityRequired: 5)]));
    pin = ok(await products.createProduct(
      name: 'Pin',
      sellPrice: 100,
      isStandalone: true,
      initialQuantity: 10,
      initialUnitCost: 20,
    ));
  });

  tearDown(() => db.close());

  OrderItemInput line(int productId, String name, int qty, double price) =>
      OrderItemInput(
          productId: productId,
          productName: name,
          quantity: qty,
          unitPrice: price);

  Future<int> create(List<OrderItemInput> items) async {
    final sales = items.fold<double>(0, (s, i) => s + i.subtotal);
    return ok(await createOrder(
      customerName: 'Maria',
      orderDate: day,
      shipByDate: day.add(const Duration(days: 2)),
      channelId: channelA,
      totalSales: sales,
      channelFees: sales * 0.1,
      shippingCost: 0,
      items: items,
    ));
  }

  Future<Result<void>> edit(
    int id,
    List<OrderItemInput> items, {
    String name = 'Maria',
    String? note,
    int? channelId,
    DateTime? shipBy,
  }) =>
      updateOrder(
        orderId: id,
        customerName: name,
        note: note,
        orderDate: day,
        shipByDate: shipBy ?? day.add(const Duration(days: 2)),
        channelId: channelId ?? channelA,
        items: items,
      );

  Future<int> promisedYarn() async =>
      ok(await materials.getMaterialById(yarn))!.quantityPromised;

  group('pending orders', () {
    test('changing items re-balances reservations and money', () async {
      final id = await create([line(tulip, 'Tulip', 2, 450)]); // 6 yarn
      expect(await promisedYarn(), 6);

      ok(await edit(id, [line(rose, 'Rose', 1, 300)])); // 5 yarn

      expect(await promisedYarn(), 5, reason: 'old 6 released, new 5 reserved');
      final order = ok(await orders.getOrderById(id))!;
      expect(order.totalSales, 300);
      expect(order.channelFees, 30);
      expect(order.totalMaterialCost, 50);
      expect(order.profit, 300 - 50 - 30);
      final lines = ok(await orders.getOrderItems(id));
      expect(lines.map((l) => l.productName), ['Rose']);
      expect(ok(await orders.getOrderMaterials(id)).single.plannedQuantity, 5);
    });

    test('standalone product stock is released and re-reserved', () async {
      final id = await create([line(pin, 'Pin', 4, 100)]);
      expect(ok(await products.getProductById(pin))!.quantityPromised, 4);

      ok(await edit(id, [line(pin, 'Pin', 7, 100)]));

      expect(ok(await products.getProductById(pin))!.quantityPromised, 7);
      expect(ok(await orders.getOrderProducts(id)).single.quantity, 7);
    });

    test('details-only change keeps reservations the same', () async {
      final id = await create([line(tulip, 'Tulip', 2, 450)]);
      ok(await edit(id, [line(tulip, 'Tulip', 2, 450)],
          name: 'Maria L.', note: 'Gift'));
      expect(await promisedYarn(), 6);
      final order = ok(await orders.getOrderById(id))!;
      expect((order.customerName, order.note), ('Maria L.', 'Gift'));
    });

    test('keeps recorded waste on a line whose quantity did not change',
        () async {
      final id = await create(
          [line(tulip, 'Tulip', 2, 450), line(pin, 'Pin', 1, 100)]);
      final planned = ok(await orders.getOrderMaterials(id)).single;
      ok(await orders.adjustMaterialsUsed(id, [
        OrderMaterialInput(
          materialId: yarn,
          materialName: 'Yarn',
          plannedQuantity: planned.plannedQuantity,
          actualQuantity: planned.plannedQuantity + 2,
          wasteQuantity: 2,
          wasteReason: 'Knotted',
          unitCost: planned.unitCost,
        ),
      ]));

      ok(await edit(
          id, [line(tulip, 'Tulip', 2, 450), line(pin, 'Pin', 3, 100)]));

      final kept = ok(await orders.getOrderMaterials(id)).single;
      expect((kept.actualQuantity, kept.wasteQuantity, kept.wasteReason),
          (8, 2, 'Knotted'));
    });

    test('changing channel recalculates fees and shipping', () async {
      final id = await create([line(tulip, 'Tulip', 1, 450)]);
      ok(await edit(id, [line(tulip, 'Tulip', 1, 450)], channelId: channelB));
      final order = ok(await orders.getOrderById(id))!;
      expect(order.channelId, channelB);
      expect(order.channelFees, 0);
      expect(order.shippingCost, 20);
    });

    test('rejects an empty item list, a blank name and an inverted date range',
        () async {
      final id = await create([line(tulip, 'Tulip', 1, 450)]);
      expect(await edit(id, []), isA<Error<void>>());
      expect(await edit(id, [line(tulip, 'Tulip', 1, 450)], name: ' '),
          isA<Error<void>>());
      expect(
        await edit(id, [line(tulip, 'Tulip', 1, 450)],
            shipBy: day.subtract(const Duration(days: 1))),
        isA<Error<void>>(),
      );
      expect(await promisedYarn(), 3,
          reason: 'a rejected edit changes nothing');
    });

    test('unknown order fails with NotFound', () async {
      expect(
          await edit(999, [line(tulip, 'Tulip', 1, 450)]), isA<Error<void>>());
    });
  });

  group('packed orders', () {
    Future<int> packed() async {
      final id = await create([line(tulip, 'Tulip', 2, 450)]);
      ok(await packOrder(id));
      return id;
    }

    test('details and channel change, items and stock do not', () async {
      final id = await packed();
      final onHandBefore =
          ok(await materials.getMaterialById(yarn))!.quantityOnHand;

      // A different item list is ignored for packed orders.
      ok(await edit(id, [line(rose, 'Rose', 9, 300)],
          name: 'Maria L.', channelId: channelB));

      final order = ok(await orders.getOrderById(id))!;
      expect(order.customerName, 'Maria L.');
      expect(order.channelId, channelB);
      expect(order.channelFees, 0);
      expect(order.shippingCost, 20);
      expect(order.totalSales, 900);
      expect(order.profit, 900 - order.totalMaterialCost - 0 - 20);
      expect(ok(await orders.getOrderItems(id)).single.productName, 'Tulip');
      expect(ok(await materials.getMaterialById(yarn))!.quantityOnHand,
          onHandBefore);
    });
  });

  group('shipped and cancelled orders', () {
    test('shipped orders only take a new note', () async {
      final id = await create([line(tulip, 'Tulip', 2, 450)]);
      ok(await packOrder(id));
      ok(await orders.shipOrder(id));

      ok(await edit(id, [],
          name: 'Someone else', note: 'Left at door', channelId: channelB));

      final order = ok(await orders.getOrderById(id))!;
      expect(order.note, 'Left at door');
      expect(order.customerName, 'Maria');
      expect(order.channelId, channelA);
      expect(order.status, OrderStatus.shipped);
    });
  });
}
