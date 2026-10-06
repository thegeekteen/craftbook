import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/utils/quantity.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/debug/domain/entities/seed_outcome.dart';
import 'package:craftbook/features/debug/domain/usecases/seed_fake_shop.dart';
import 'package:craftbook/features/earnings/domain/usecases/get_earnings_summary.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_money.dart';
import 'package:craftbook/features/order_fields/domain/repositories/order_field_repository.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/get_receivables.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/entities/buy_list_item.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

T _ok<T>(Result<T> result) => switch (result) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// A fresh in-memory database with everything registered, as on a new phone.
Future<AppDatabase> _freshDatabase() async {
  await getIt.reset();
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await configureDependencies(database: db);
  return db;
}

/// Runs a seed and fails the test with the seeder's own words if it refused.
Future<SeedOutcome> _seed({int? seed}) async {
  final result = await getIt<SeedFakeShop>()(seed: seed);
  return switch (result) {
    Error(:final failure) =>
      fail('the seed was rolled back: ${failure.message}'),
    Success(:final value) => value,
  };
}

void main() {
  group('SeedFakeShop', () {
    late AppDatabase db;

    setUp(() async {
      db = await _freshDatabase();
    });

    tearDown(() async {
      await db.close();
      await getIt.reset();
    });

    test('the standard shop covers every option the app offers', () async {
      final outcome = await _seed();
      expect(outcome.coverage.gaps, isEmpty);
      expect(outcome.orders, greaterThan(20));
      expect(outcome.buyListLines, greaterThan(0));
    });

    test('every seed covers the same ground', () async {
      // A coverage contract that only holds for one shop is a fixture, not a
      // guarantee: randomising quantities must not be able to lose a status or
      // a fee shape.
      for (final seed in [1, 7, 99, 20260101, 555555]) {
        await db.close();
        db = await _freshDatabase();
        final outcome = await _seed(seed: seed);
        expect(outcome.coverage.gaps, isEmpty, reason: 'seed $seed');
      }
    });

    test('open orders hold pieces and packed ones spent them', () async {
      await _seed();
      final materials =
          _ok(await getIt<MaterialRepository>().getAllMaterials());
      expect(materials.any((m) => m.quantityPromised > 0), isTrue,
          reason: 'nothing is reserved, so the pip strip has nothing to hatch');
      expect(materials.any((m) => m.quantityOnHand == 0), isTrue,
          reason: 'no shelf came out empty');
      expect(
          materials.any((m) => m.quantityPromised > m.quantityOnHand), isTrue,
          reason: 'nothing is promised beyond the shelf, so the shortfall '
              'message was never drawn');

      var deducted = 0;
      for (final material in materials) {
        final movements = _ok(
            await getIt<MaterialRepository>().getStockMovements(material.id!));
        deducted += movements.where((m) => m.type.name == 'deducted').length;
      }
      expect(deducted, greaterThan(0),
          reason: 'packing never took anything off a shelf');
    });

    test('waste is recorded, with a reason when there is waste', () async {
      await _seed();
      final orders = _ok(await getIt<OrderRepository>().getAllOrders());
      var waste = 0;
      var withReason = 0;
      var under = 0;
      for (final order in orders) {
        for (final line in _ok(
            await getIt<OrderRepository>().getOrderMaterials(order.id!))) {
          if (line.wasteQuantity > 0) {
            waste++;
            if (line.wasteReason != null) withReason++;
          }
          if (line.actualQuantity < line.plannedQuantity) under++;
        }
      }
      expect(waste, greaterThan(0),
          reason: 'no order ever used more than it planned');
      expect(withReason, waste);
      expect(under, greaterThan(0),
          reason: 'no order ever used less than it planned');
    });

    test('stored profit agrees with the money worked out from its parts',
        () async {
      await _seed();
      final orders = _ok(await getIt<OrderRepository>().getAllOrders());
      for (final order in orders) {
        final live = OrderMoney.fromOrder(order);
        expect(order.profit, closeTo(live.profit, 0.01),
            reason: '${order.customerName}: stored ${order.profit} but the '
                'parts say ${live.profit} (discount ${live.discount}, tax '
                '${live.tax}, materials ${live.materials}, fees ${live.fees}, '
                'shipping ${live.shipping})');
      }
    });

    test('only open orders leave a promise on the shelf', () async {
      await _seed();
      final orders = _ok(await getIt<OrderRepository>().getAllOrders());
      final cancelled =
          orders.where((o) => o.status == OrderStatus.cancelled).toList();
      expect(cancelled.length, greaterThan(1));

      // Packing releases what was reserved and takes the pieces off the shelf,
      // and cancelling gives back what a packed order had spent — so after all
      // of that, only orders still to pack should be holding anything.
      final held = <int, double>{};
      for (final order
          in orders.where((o) => o.status == OrderStatus.pending)) {
        for (final line in _ok(
            await getIt<OrderRepository>().getOrderMaterials(order.id!))) {
          held[line.materialId] =
              qty((held[line.materialId] ?? 0) + line.plannedQuantity);
        }
      }
      final materials =
          _ok(await getIt<MaterialRepository>().getAllMaterials());
      for (final material in materials) {
        expect(
            material.quantityPromised, closeTo(held[material.id!] ?? 0, 0.01),
            reason: '${material.name} promises ${material.quantityPromised} '
                'but only ${held[material.id!]} is owed to orders still to '
                'pack');
      }
    });

    test('the buy list has materials, a resell product, and waiting orders',
        () async {
      await _seed();
      final buyList = _ok(await getIt<MaterialRepository>().getBuyList());
      expect(buyList.any((i) => i.kind == BuyListKind.material), isTrue);
      expect(buyList.any((i) => i.kind == BuyListKind.product), isTrue);
      expect(buyList.any((i) => i.packsToOrder > 1), isTrue,
          reason: 'nothing needs more than one pack, so the pack maths was '
              'never drawn');
      expect(buyList.any((i) => i.blockingOrders > 0), isTrue,
          reason: 'nothing on the list has an order waiting on it');
      expect(
          buyList.any((i) =>
              !sameQty(i.quantityOnHand, i.quantityOnHand.roundToDouble())),
          isTrue,
          reason: 'no fractional number reached the list');
      expect(
          buyList.any((i) => sameQty(i.quantityOnHand, i.alertLevel)), isTrue,
          reason: 'nothing sat exactly at its reorder level');
    });

    test('an archived material that orders used stays off the buy list',
        () async {
      await _seed();
      final materials =
          _ok(await getIt<MaterialRepository>().getAllMaterials());
      final archivedLow = materials
          .where((m) => m.isArchived && m.quantityOnHand <= m.alertLevel)
          .toList();
      expect(archivedLow, isNotEmpty);
      final buyList = _ok(await getIt<MaterialRepository>().getBuyList());
      for (final archived in archivedLow) {
        expect(buyList.map((i) => i.id), isNot(contains(archived.id)));
      }
    });

    test('retires a material, a product and a field, each still on orders',
        () async {
      await _seed();
      final materials =
          _ok(await getIt<MaterialRepository>().getAllMaterials());
      final products = _ok(await getIt<ProductRepository>().getAllProducts());
      final fields = _ok(await getIt<OrderFieldRepository>().getFields());

      final archivedMaterials = materials.where((m) => m.isArchived).toList();
      final archivedProducts = products.where((p) => p.isArchived).toList();
      final archivedFields = fields.where((f) => f.isArchived).toList();
      expect(archivedMaterials, isNotEmpty,
          reason: 'nothing on the shelf was retired');
      expect(archivedProducts, isNotEmpty,
          reason: 'no product was retired, so the Archived chip has nothing '
              'to show');
      expect(archivedFields, isNotEmpty, reason: 'no order field was retired');

      // Archiving is what you do to something that is still referenced, so
      // each one has to keep showing on the orders that used it.
      expect(
          _ok(await getIt<MaterialRepository>()
              .isUsedInOrders(archivedMaterials.first.id!)),
          isTrue);
      expect(
          _ok(await getIt<ProductRepository>()
              .hasOrdersUsingProduct(archivedProducts.first.id!)),
          isTrue);
      expect(archivedFields.first.usageCount, greaterThan(0));
    });

    test('receivables and reports both have something in them', () async {
      await _seed();
      final receivables = _ok(await getIt<GetReceivables>()());
      expect(receivables.orderCount, greaterThan(0));
      expect(receivables.total, greaterThan(0));

      final now = DateTime.now();
      final summary = _ok(await getIt<GetEarningsSummary>()(
          DateTime(now.year, now.month), now));
      expect(summary.orderCount, greaterThan(0),
          reason: 'this month is empty, so the reports screen has nothing to '
              'check itself against');
      expect(summary.unpaidTotal, greaterThan(0));
    });

    test('seeding twice leaves one shop, not two', () async {
      final first = await _seed();
      final second = await _seed();
      expect(second.orders, first.orders);
      expect(_ok(await getIt<OrderRepository>().getAllOrders()).length,
          second.orders);
      expect(_ok(await getIt<ProductRepository>().getAllProducts()).length,
          second.products);
    });

    test('the same seed rebuilds the same shop, ids included', () async {
      await _seed();
      final firstIds = _ok(await getIt<OrderRepository>().getAllOrders())
          .map((o) => o.id)
          .toList();
      await _seed();
      final secondIds = _ok(await getIt<OrderRepository>().getAllOrders())
          .map((o) => o.id)
          .toList();
      // A wipe has to reset the autoincrement counters as well as the rows, or
      // the second run starts at order 35 and two builds of one seed stop being
      // comparable — which is the whole reason the seed is fixed.
      expect(secondIds, firstIds);
      expect(secondIds.first, 1);
    });
  });
}
