import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/database/daos/earnings_dao.dart';
import 'package:craftbook/database/daos/material_dao.dart';
import 'package:craftbook/database/daos/order_dao.dart';
import 'package:craftbook/database/daos/product_dao.dart';
import 'package:craftbook/features/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:craftbook/features/orders/data/repositories/order_repository_impl.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart'
    show OrderStatus;
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/products/data/repositories/product_repository_impl.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/data/repositories/material_repository_impl.dart';
import 'package:craftbook/features/stock/domain/entities/buy_list_item.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Repository behaviour against a real (in-memory) SQLite database.
void main() {
  late AppDatabase db;
  late MaterialRepositoryImpl materials;
  late OrderRepositoryImpl orders;
  late EarningsRepositoryImpl earnings;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    materials = MaterialRepositoryImpl(MaterialDao(db), ProductDao(db));
    orders = OrderRepositoryImpl(OrderDao(db));
    earnings = EarningsRepositoryImpl(EarningsDao(db));
  });

  tearDown(() => db.close());

  Future<int> material(
      {int onHand = 10, int promised = 0, int alert = 5, int pack = 10}) async {
    final id = ok(await materials.createMaterial(
      name: 'Yarn',
      packSize: pack,
      packPrice: 100,
      unitCost: 100 / pack,
      quantityOnHand: onHand,
      alertLevel: alert,
    ));
    if (promised > 0) await materials.reserveMaterials(id, promised);
    return id;
  }

  Future<int> productId() =>
      db.into(db.products).insert(ProductsCompanion.insert(
            name: 'Tulip',
            sellPrice: 450,
          ));

  Future<int> order({
    required int product,
    required DateTime shipBy,
    List<OrderMaterialInput> materials = const [],
    int qty = 1,
  }) async =>
      ok(await orders.createOrder(
        customerName: 'Maria',
        orderDate: shipBy.subtract(const Duration(days: 2)),
        shipByDate: shipBy,
        channelId: 1,
        totalSales: 450.0 * qty,
        totalMaterialCost: 50,
        channelFees: 10,
        shippingCost: 0,
        profit: 0,
        items: [
          OrderItemInput(
              productId: product,
              productName: 'Tulip',
              quantity: qty,
              unitPrice: 450)
        ],
        materials: materials,
      ));

  group('deductMaterials', () {
    test('releases only the reserved amount from promised', () async {
      final id = await material(onHand: 20, promised: 10);
      await materials.deductMaterials(id, 8, reserved: 6);
      final m = ok(await materials.getMaterialById(id))!;
      expect(m.quantityOnHand, 12);
      expect(m.quantityPromised, 4, reason: "another order's 4 stay promised");
    });

    test('defaults reserved to the deducted amount', () async {
      final id = await material(onHand: 20, promised: 10);
      await materials.deductMaterials(id, 6);
      final m = ok(await materials.getMaterialById(id))!;
      expect(m.quantityPromised, 4);
    });
  });

  group('updateMaterial', () {
    test('edits master data without touching stock counts', () async {
      final id = await material(onHand: 40, promised: 15);
      ok(await materials.updateMaterial(
        id: id,
        name: 'Wool',
        packSize: 10,
        packPrice: 100,
        alertLevel: 8,
        supplier: 'Local shop',
      ));
      final m = ok(await materials.getMaterialById(id))!;
      expect(m.name, 'Wool');
      expect(m.alertLevel, 8);
      expect(m.supplier, 'Local shop');
      expect(m.quantityOnHand, 40);
      expect(m.quantityPromised, 15);
    });

    test('keeps the weighted-average cost when price and pack are unchanged',
        () async {
      final id = await material(pack: 10);
      ok(await materials.receiveStock(
          materialId: id, packsReceived: 1, pricePerPack: 200));
      final before = ok(await materials.getMaterialById(id))!;
      ok(await materials.updateMaterial(
        id: id,
        name: 'Renamed',
        packSize: before.packSize,
        packPrice: before.packPrice,
        alertLevel: before.alertLevel,
      ));
      expect(
          ok(await materials.getMaterialById(id))!.unitCost, before.unitCost);
    });

    test('resets unit cost to packPrice / packSize when the price changes',
        () async {
      final id = await material(pack: 10);
      ok(await materials.updateMaterial(
        id: id,
        name: 'Yarn',
        packSize: 20,
        packPrice: 100,
        alertLevel: 5,
      ));
      expect(ok(await materials.getMaterialById(id))!.unitCost, 5);
    });

    test('unknown id fails with NotFound', () async {
      final r = await materials.updateMaterial(
        id: 999,
        name: 'x',
        packSize: 1,
        packPrice: 1,
        alertLevel: 0,
      );
      expect(r, isA<Error<void>>());
    });
  });

  group('updateProduct', () {
    test('clears the description when given an empty one', () async {
      final repo = ProductRepositoryImpl(ProductDao(db));
      final id = ok(await repo.createProduct(
          name: 'Tulip', description: 'Pink', sellPrice: 450));
      ok(await repo.updateProduct(id: id, description: ''));
      expect(ok(await repo.getProductById(id))!.description, isNull);
    });

    test('null description and unitCost leave existing values alone', () async {
      final repo = ProductRepositoryImpl(ProductDao(db));
      final id = ok(await repo.createProduct(
        name: 'Pin',
        description: 'Gold',
        sellPrice: 100,
        isStandalone: true,
        initialQuantity: 5,
        initialUnitCost: 20,
      ));
      ok(await repo.updateProduct(id: id, name: 'Pin v2'));
      var p = ok(await repo.getProductById(id))!;
      expect((p.name, p.description, p.unitCost, p.quantityOnHand),
          ('Pin v2', 'Gold', 20.0, 5));

      ok(await repo.updateProduct(id: id, unitCost: 25));
      p = ok(await repo.getProductById(id))!;
      expect((p.unitCost, p.quantityOnHand), (25.0, 5));
    });

    test('keeps the photo when other fields change', () async {
      final repo = ProductRepositoryImpl(ProductDao(db));
      final id = ok(await repo.createProduct(name: 'Tulip', sellPrice: 450));
      final photo = Uint8List.fromList([1, 2, 3, 4]);
      ok(await repo.setProductPhoto(id, photo));

      ok(await repo.updateProduct(id: id, name: 'Tulip v2', sellPrice: 500));
      final p = ok(await repo.getProductById(id))!;
      expect((p.name, p.sellPrice), ('Tulip v2', 500.0));
      expect(p.photo, photo);
    });

    test('saveBomItems replaces the previous BOM', () async {
      final repo = ProductRepositoryImpl(ProductDao(db));
      final id = ok(await repo.createProduct(name: 'Tulip', sellPrice: 450));
      final yarn = await material();
      ok(await repo.saveBomItems(
          id, [BomItemInput(materialId: yarn, quantityRequired: 2)]));
      ok(await repo.saveBomItems(
          id, [BomItemInput(materialId: yarn, quantityRequired: 5)]));
      final bom = ok(await repo.getBomItems(id));
      expect(bom.map((b) => b.quantityRequired), [5]);
    });
  });

  group('setProductPhoto', () {
    test('stores a photo and clears it again', () async {
      final repo = ProductRepositoryImpl(ProductDao(db));
      final id = ok(await repo.createProduct(name: 'Tulip', sellPrice: 450));
      expect(ok(await repo.getProductById(id))!.photo, isNull);

      final photo = Uint8List.fromList([0xFF, 0xD8, 0xFF, 9]);
      expect(await repo.setProductPhoto(id, photo), const Success<void>(null));
      final withPhoto = ok(await repo.getProductById(id))!;
      expect(withPhoto.photo, photo);
      expect(withPhoto.name, 'Tulip');

      ok(await repo.setProductPhoto(id, null));
      expect(ok(await repo.getProductById(id))!.photo, isNull);
    });

    test('reports a missing product', () async {
      final repo = ProductRepositoryImpl(ProductDao(db));
      final result = await repo.setProductPhoto(999, Uint8List(3));
      expect(result, isA<Error<void>>());
      expect((result as Error<void>).failure, isA<NotFoundFailure>());
    });
  });

  group('getBuyList', () {
    test('suggests at least one pack for an item sitting at its reorder level',
        () async {
      await material(onHand: 5, alert: 5);
      final item = ok(await materials.getBuyList()).single;
      expect(item.packsToOrder, 1);
      expect(item.totalCost, 100);
    });

    test('covers the reorder level plus promised pieces', () async {
      await material(onHand: 7, promised: 15, alert: 10, pack: 10);
      final item = ok(await materials.getBuyList()).single;
      expect(
          item.packsToOrder, 2); // needs 25, has 7 → 18 short → 2 packs of 10
    });
  });

  group('resell on the buy list', () {
    Future<int> resell({
      int onHand = 1,
      int alert = 3,
      bool active = true,
      double unitCost = 25,
    }) =>
        db.into(db.products).insert(ProductsCompanion.insert(
              name: 'Gift box',
              sellPrice: 60,
              isStandalone: const Value(true),
              isActive: Value(active),
              quantityOnHand: Value(onHand),
              alertLevel: Value(alert),
              unitCost: Value(unitCost),
            ));

    test('lists a low resell product by the piece after materials', () async {
      await material(onHand: 2, alert: 5);
      final id = await resell(onHand: 1, alert: 3);
      await ProductRepositoryImpl(ProductDao(db)).reserveProductStock(id, 2);

      final items = ok(await materials.getBuyList());
      expect(items.map((i) => i.kind),
          [BuyListKind.material, BuyListKind.product]);
      final box = items.last;
      expect(box.id, id);
      expect(box.name, 'Gift box');
      expect(box.packSize, 1);
      // Needs 3 + 2 promised, has 1 → 4 pieces.
      expect(box.packsToOrder, 4);
      expect(box.totalCost, 100);
      expect(box.blockedProducts, isEmpty);
    });

    test('counts pending orders for the resell product', () async {
      final id = await resell(onHand: 0);
      await order(product: id, shipBy: DateTime(2026, 10, 4));
      final packed = await order(product: id, shipBy: DateTime(2026, 10, 4));
      await orders.packOrder(packed);

      final box = ok(await materials.getBuyList()).single;
      expect(box.ownOpenOrders, 1);
      expect(box.blockingOrders, 1);
    });

    test('skips inactive, above-alert and alert-less products', () async {
      await resell(onHand: 0, active: false);
      await resell(onHand: 5, alert: 3);
      await resell(onHand: 0, alert: 0);
      expect(ok(await materials.getBuyList()), isEmpty);
    });
  });

  group('pendingOrderCounts', () {
    test('counts only pending orders, per product', () async {
      final a = await productId();
      final b = await productId();
      await order(product: a, shipBy: DateTime(2026, 10, 4));
      await order(product: a, shipBy: DateTime(2026, 10, 5));
      await order(product: b, shipBy: DateTime(2026, 10, 4));
      final packed = await order(product: b, shipBy: DateTime(2026, 10, 4));
      await orders.packOrder(packed);
      final shipped = await order(product: b, shipBy: DateTime(2026, 10, 4));
      await orders.packOrder(shipped);
      await orders.shipOrder(shipped);

      final counts = ok(
          await ProductRepositoryImpl(ProductDao(db)).getPendingOrderCounts());
      expect(counts, {a: 2, b: 1});
    });
  });

  group('orders', () {
    test(
        'getOpenOrdersDueBefore returns pending and packed orders due before the date',
        () async {
      final p = await productId();
      final overdue = await order(product: p, shipBy: DateTime(2026, 10, 3));
      final today = await order(product: p, shipBy: DateTime(2026, 10, 4, 9));
      await order(product: p, shipBy: DateTime(2026, 10, 6));
      final shipped = await order(product: p, shipBy: DateTime(2026, 10, 2));
      await orders.packOrder(shipped);
      await orders.shipOrder(shipped);

      final due =
          ok(await orders.getOpenOrdersDueBefore(DateTime(2026, 10, 5)));
      expect(due.map((o) => o.id), [overdue, today]);
    });

    test('getOrderLines returns product names and quantities per order',
        () async {
      final p = await productId();
      final a = await order(product: p, shipBy: DateTime(2026, 10, 4), qty: 2);
      final b = await order(product: p, shipBy: DateTime(2026, 10, 4));
      final lines = ok(await orders.getOrderLines([a, b]));
      expect(lines[a]!.single.quantity, 2);
      expect(lines[a]!.single.productName, 'Tulip');
      expect(lines[b]!.single.quantity, 1);
    });

    test('getOrderItems carries the product photo', () async {
      final p = await productId();
      final photo = Uint8List.fromList([7, 8, 9]);
      await ProductDao(db).setProductPhoto(p, photo);
      final id = await order(product: p, shipBy: DateTime(2026, 10, 4));

      final item = ok(await orders.getOrderItems(id)).single;
      expect(item.productName, 'Tulip');
      expect(item.productPhoto, photo);
    });

    test('updateOrderNote changes only the note, even on a shipped order',
        () async {
      final p = await productId();
      final id = await order(product: p, shipBy: DateTime(2026, 10, 4));
      await orders.packOrder(id);
      await orders.shipOrder(id);

      expect(await orders.updateOrderNote(id, 'Ring twice'),
          const Success<void>(null));
      final saved = ok(await orders.getOrderById(id))!;
      expect(saved.note, 'Ring twice');
      expect(saved.status, OrderStatus.shipped);
      expect(saved.customerName, 'Maria');

      await orders.updateOrderNote(id, null);
      expect(ok(await orders.getOrderById(id))!.note, isNull);
    });

    test('updateOrderNote reports a missing order', () async {
      final result = await orders.updateOrderNote(999, 'Ring twice');
      expect(result, isA<Error<void>>());
      expect((result as Error<void>).failure, isA<NotFoundFailure>());
    });
  });

  group('earnings', () {
    test('waste counts for the period the order was completed in', () async {
      final p = await productId();
      final m = await material(onHand: 50);
      final id = await order(
        product: p,
        shipBy: DateTime(2026, 9, 10),
        materials: [
          OrderMaterialInput(
              materialId: m,
              materialName: 'Yarn',
              plannedQuantity: 3,
              actualQuantity: 3,
              unitCost: 10)
        ],
      );
      await orders.adjustMaterialsUsed(id, [
        OrderMaterialInput(
            materialId: m,
            materialName: 'Yarn',
            plannedQuantity: 3,
            actualQuantity: 5,
            wasteQuantity: 2,
            unitCost: 10),
      ]);
      await orders.packOrder(id);
      // Packed in October although its material rows were created in September.
      await (db.update(db.orders)..where((t) => t.id.equals(id)))
          .write(OrdersCompanion(packedAt: Value(DateTime(2026, 10, 2))));
      await (db.update(db.orderMaterials)..where((t) => t.orderId.equals(id)))
          .write(
              OrderMaterialsCompanion(createdAt: Value(DateTime(2026, 9, 8))));

      final waste = ok(await earnings.getWasteSummary(
          DateTime(2026, 10, 1), DateTime(2026, 10, 31, 23, 59)));
      expect(waste.totalWasteQuantity, 2);
      expect(waste.totalWasteCost, 20);
    });

    test('profit points and product order lines follow completion dates',
        () async {
      final p = await productId();
      final id = await order(product: p, shipBy: DateTime(2026, 10, 2), qty: 2);
      await orders.packOrder(id);
      await (db.update(db.orders)..where((t) => t.id.equals(id)))
          .write(OrdersCompanion(packedAt: Value(DateTime(2026, 10, 2, 12))));

      final from = DateTime(2026, 10, 1);
      final to = DateTime(2026, 10, 7, 23, 59);
      final points = ok(await earnings.getCompletedOrderProfits(from, to));
      expect(points.single.completedAt, DateTime(2026, 10, 2, 12));
      expect(points.single.profit, 900 - 50 - 10);

      final lines = ok(await earnings.getProductOrderLines(p, from, to));
      expect(lines.single.quantity, 2);
      expect(lines.single.profit, closeTo(840, 0.001));

      expect(
          ok(await earnings.getCompletedOrderProfits(
              DateTime(2026, 11), DateTime(2026, 11, 30))),
          isEmpty);
    });
  });

  group('product history', () {
    test('getProductSales lists the product in every order, dated by its stage',
        () async {
      final products = ProductRepositoryImpl(ProductDao(db));
      final id = await productId();
      final pending = await order(product: id, shipBy: DateTime(2026, 3, 10));
      final packed =
          await order(product: id, shipBy: DateTime(2026, 3, 5), qty: 2);
      ok(await orders.packOrder(packed));
      await order(product: await productId(), shipBy: DateTime(2026, 3, 1));

      final sales = ok(await products.getProductSales(id));

      expect(sales.map((s) => s.orderId), unorderedEquals([pending, packed]));
      final p = sales.firstWhere((s) => s.orderId == pending);
      expect(p.status, OrderStatus.pending);
      expect(p.date, DateTime(2026, 3, 8),
          reason: 'pending orders use the order date');
      expect(p.customerName, 'Maria');
      final k = sales.firstWhere((s) => s.orderId == packed);
      expect(k.status, OrderStatus.packed);
      expect(k.quantity, 2);
      expect(k.subtotal, 900);
      expect(k.date.isAfter(DateTime(2026, 3, 3)), isTrue,
          reason: 'packed orders use packedAt');
    });

    test('adjustProductStock keeps the sign of a count that lowers stock',
        () async {
      final products = ProductRepositoryImpl(ProductDao(db));
      final id = ok(await products.createProduct(
        name: 'Gift box',
        sellPrice: 60,
        isStandalone: true,
        initialQuantity: 6,
        initialUnitCost: 28,
      ));

      ok(await products.adjustProductStock(
          productId: id, newQuantityOnHand: 4));
      ok(await products.adjustProductStock(
          productId: id, newQuantityOnHand: 7));

      final counts = ok(await products.getProductStockMovements(id))
          .where((m) => m.reference?.startsWith('Adjusted') == true)
          .map((m) => m.quantity);
      expect(counts, unorderedEquals([-2, 3]));
    });
  });
}
