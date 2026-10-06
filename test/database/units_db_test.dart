import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/database/daos/material_dao.dart';
import 'package:craftbook/database/daos/order_dao.dart';
import 'package:craftbook/database/daos/product_dao.dart';
import 'package:craftbook/database/daos/unit_dao.dart';
import 'package:craftbook/database/seed_units.dart';
import 'package:craftbook/features/orders/data/repositories/order_repository_impl.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/products/data/repositories/product_repository_impl.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/data/repositories/material_repository_impl.dart';
import 'package:craftbook/features/units/data/repositories/unit_repository_impl.dart';
import 'package:craftbook/features/units/domain/entities/unit_of_measure.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Units of measure against a real (in-memory) SQLite database.
void main() {
  late AppDatabase db;
  late UnitRepositoryImpl units;
  late MaterialRepositoryImpl materials;
  late ProductRepositoryImpl products;
  late OrderRepositoryImpl orders;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    units = UnitRepositoryImpl(UnitDao(db));
    materials = MaterialRepositoryImpl(MaterialDao(db), ProductDao(db));
    products = ProductRepositoryImpl(ProductDao(db));
    orders = OrderRepositoryImpl(OrderDao(db));
  });

  tearDown(() => db.close());

  Future<UnitOfMeasure> find(String label) async =>
      ok(await units.getUnits()).firstWhere((u) => u.label == label);

  Future<int> material({String name = 'Board', int? unitId}) => materials
      .createMaterial(
        name: name,
        unitId: unitId,
        packSize: 1,
        packPrice: 40,
        unitCost: 40,
        quantityOnHand: 5,
        alertLevel: 2,
      )
      .then(ok);

  group('seeding', () {
    test('a fresh database gets the built-in units with pc as the default',
        () async {
      final all = ok(await units.getUnits());
      expect(all.map((u) => u.label), seedUnitLabels);
      expect(all.map((u) => u.position), List.generate(all.length, (i) => i));
      expect(all.where((u) => u.isDefault).map((u) => u.label), ['pc']);
      expect(ok(await units.getDefaultUnit())?.label, 'pc');
    });
  });

  group('saving', () {
    test('adds a unit at the end of the list', () async {
      ok(await units.createUnit(const UnitOfMeasure(label: 'board')));
      final all = ok(await units.getUnits());
      expect(all.last.label, 'board');
      expect(all.last.position, seedUnitLabels.length);
      expect(all.last.isDefault, isFalse);
    });

    test('renaming reaches the materials using it', () async {
      final sheet = await find('sheet');
      final id = await material(unitId: sheet.id);
      expect(ok(await materials.getMaterialById(id))!.unit, 'sheet');

      ok(await units
          .updateUnit(UnitOfMeasure(id: sheet.id, label: 'sheet of A4')));
      final renamed = ok(await materials.getMaterialById(id));
      expect((renamed!.unitId, renamed.unit), (sheet.id, 'sheet of A4'));
    });

    test('a duplicate label is refused', () async {
      // SaveUnit checks first for a readable message; the UNIQUE constraint
      // is the backstop, and the repository turns it into a failure.
      expect(await units.createUnit(const UnitOfMeasure(label: 'pc')),
          isA<Error<int>>());
    });
  });

  group('the default unit', () {
    test('setting a new default clears the old one', () async {
      final kg = await find('kg');
      ok(await units.setDefaultUnit(kg.id!));
      final all = ok(await units.getUnits());
      expect(all.where((u) => u.isDefault).map((u) => u.label), ['kg']);
      expect(ok(await units.getDefaultUnit())?.label, 'kg');
    });

    test('deleting an unused default hands it to the next unit', () async {
      final pc = await find('pc');
      ok(await units.deleteUnit(pc.id!));
      // 'pc' was first and nothing was counted in it, so 'sheet' takes over.
      expect(ok(await units.getDefaultUnit())?.label, 'sheet');
      expect(ok(await units.getUnits()).where((u) => u.isDefault).length, 1);
    });
  });

  group('reordering', () {
    test('writes the positions in list order', () async {
      final reversed =
          ok(await units.getUnits()).reversed.map((u) => u.id!).toList();
      ok(await units.reorder(reversed));
      expect(ok(await units.getUnits()).map((u) => u.label),
          seedUnitLabels.reversed.toList());
    });
  });

  group('a new item starts on the default unit', () {
    test('material', () async {
      expect(ok(await materials.getMaterialById(await material()))!.unit, 'pc');
    });

    test('material with an explicit unit', () async {
      final kg = await find('kg');
      final saved =
          ok(await materials.getMaterialById(await material(unitId: kg.id)));
      expect((saved!.unitId, saved.unit), (kg.id, 'kg'));
    });

    test('product', () async {
      final id = ok(await products.createProduct(
          name: 'Bubble head', sellPrice: 120, isStandalone: true));
      expect(ok(await products.getProductById(id))!.unit, 'pc');
    });
  });

  group('a renamed unit reaches past orders', () {
    /// An order whose single material line points at [materialId].
    Future<int> orderUsing(int materialId) async {
      final productId =
          ok(await products.createProduct(name: 'Card', sellPrice: 3));
      ok(await products.saveBomItems(productId, [
        BomItemInput(materialId: materialId, quantityRequired: 1),
      ]));
      return ok(await orders.createOrder(
        customerName: 'Maria',
        orderDate: DateTime(2026, 3, 1),
        shipByDate: DateTime(2026, 3, 4),
        channelId: 1,
        totalSales: 3,
        totalMaterialCost: 40,
        channelFees: 0,
        shippingCost: 0,
        profit: -37,
        items: [
          OrderItemInput(
              productId: productId,
              productName: 'Card',
              quantity: 1,
              unitPrice: 3),
        ],
        materials: [
          OrderMaterialInput(
            materialId: materialId,
            materialName: 'A4 sheet',
            plannedQuantity: 1,
            actualQuantity: 1,
            unitCost: 40,
          ),
        ],
      ));
    }

    test('an order material line shows the new label', () async {
      final sheet = await find('sheet');
      final orderId = await orderUsing(await material(unitId: sheet.id));

      // The line stores no unit of its own, so it follows the rename.
      expect(ok(await orders.getOrderMaterials(orderId)).single.materialUnit,
          'sheet');
      ok(await units
          .updateUnit(UnitOfMeasure(id: sheet.id, label: 'sheet of A4')));
      expect(ok(await orders.getOrderMaterials(orderId)).single.materialUnit,
          'sheet of A4');
    });
  });

  group('usage counts', () {
    test('counts the materials and products on a unit', () async {
      final kg = await find('kg');
      await material(name: 'Glitter', unitId: kg.id);
      await material(name: 'Resin', unitId: kg.id);
      ok(await products.createProduct(
          name: 'Beads', sellPrice: 5, unitId: kg.id, isStandalone: true));
      expect(ok(await units.usageCounts(kg.id!)), (2, 1));
    });

    test('an unused unit has no counts', () async {
      expect(ok(await units.usageCounts((await find('ml')).id!)), (0, 0));
    });
  });
}
