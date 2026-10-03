import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/database/daos/earnings_dao.dart';
import 'package:craftbook/database/daos/material_dao.dart';
import 'package:craftbook/database/daos/order_dao.dart';
import 'package:craftbook/database/daos/product_dao.dart';
import 'package:craftbook/features/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:craftbook/features/orders/data/repositories/order_repository_impl.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/stock/data/repositories/material_repository_impl.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/sqlite.dart';

T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Repository behaviour against a real (in-memory) SQLite database.
void main() {
  setUpAll(useHostSqlite);

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

  Future<int> material({int onHand = 10, int promised = 0, int alert = 5, int pack = 10}) async {
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

  Future<int> productId() => db.into(db.products).insert(ProductsCompanion.insert(
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
        customerAddress: '',
        orderDate: shipBy.subtract(const Duration(days: 2)),
        shipByDate: shipBy,
        channelId: 1,
        totalSales: 450.0 * qty,
        totalMaterialCost: 50,
        channelFees: 10,
        shippingCost: 0,
        profit: 0,
        items: [OrderItemInput(productId: product, productName: 'Tulip', quantity: qty, unitPrice: 450)],
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

  group('getBuyList', () {
    test('suggests at least one pack for an item sitting at its reorder level', () async {
      await material(onHand: 5, alert: 5);
      final item = ok(await materials.getBuyList()).single;
      expect(item.packsToOrder, 1);
      expect(item.totalCost, 100);
    });

    test('covers the reorder level plus promised pieces', () async {
      await material(onHand: 7, promised: 15, alert: 10, pack: 10);
      final item = ok(await materials.getBuyList()).single;
      expect(item.packsToOrder, 2); // needs 25, has 7 → 18 short → 2 packs of 10
    });
  });

  group('orders', () {
    test('getOpenOrdersDueBefore returns pending and packed orders due before the date', () async {
      final p = await productId();
      final overdue = await order(product: p, shipBy: DateTime(2026, 10, 3));
      final today = await order(product: p, shipBy: DateTime(2026, 10, 4, 9));
      await order(product: p, shipBy: DateTime(2026, 10, 6));
      final shipped = await order(product: p, shipBy: DateTime(2026, 10, 2));
      await orders.packOrder(shipped);
      await orders.shipOrder(shipped);

      final due = ok(await orders.getOpenOrdersDueBefore(DateTime(2026, 10, 5)));
      expect(due.map((o) => o.id), [overdue, today]);
    });

    test('getOrderLines returns product names and quantities per order', () async {
      final p = await productId();
      final a = await order(product: p, shipBy: DateTime(2026, 10, 4), qty: 2);
      final b = await order(product: p, shipBy: DateTime(2026, 10, 4));
      final lines = ok(await orders.getOrderLines([a, b]));
      expect(lines[a]!.single.quantity, 2);
      expect(lines[a]!.single.productName, 'Tulip');
      expect(lines[b]!.single.quantity, 1);
    });
  });

  group('earnings', () {
    test('waste counts for the period the order was completed in', () async {
      final p = await productId();
      final m = await material(onHand: 50);
      final id = await order(
        product: p,
        shipBy: DateTime(2026, 9, 10),
        materials: [OrderMaterialInput(materialId: m, materialName: 'Yarn', plannedQuantity: 3, actualQuantity: 3, unitCost: 10)],
      );
      await orders.adjustMaterialsUsed(id, [
        OrderMaterialInput(materialId: m, materialName: 'Yarn', plannedQuantity: 3, actualQuantity: 5, wasteQuantity: 2, unitCost: 10),
      ]);
      await orders.packOrder(id);
      // Packed in October although its material rows were created in September.
      await (db.update(db.orders)..where((t) => t.id.equals(id)))
          .write(OrdersCompanion(packedAt: Value(DateTime(2026, 10, 2))));
      await (db.update(db.orderMaterials)..where((t) => t.orderId.equals(id)))
          .write(OrderMaterialsCompanion(createdAt: Value(DateTime(2026, 9, 8))));

      final waste = ok(await earnings.getWasteSummary(DateTime(2026, 10, 1), DateTime(2026, 10, 31, 23, 59)));
      expect(waste.totalWasteQuantity, 2);
      expect(waste.totalWasteCost, 20);
    });

    test('profit points and product order lines follow completion dates', () async {
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

      expect(ok(await earnings.getCompletedOrderProfits(DateTime(2026, 11), DateTime(2026, 11, 30))), isEmpty);
    });
  });
}
