import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/database/daos/order_dao.dart';
import 'package:craftbook/database/daos/order_field_dao.dart';
import 'package:craftbook/features/order_fields/data/repositories/order_field_repository_impl.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/orders/data/repositories/order_repository_impl.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart'
    show OrderStatus;
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/sqlite.dart';

T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Field definitions and order values against a real (in-memory) database.
void main() {
  setUpAll(useHostSqlite);

  late AppDatabase db;
  late OrderFieldRepositoryImpl fields;
  late OrderRepositoryImpl orders;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fields = OrderFieldRepositoryImpl(OrderFieldDao(db));
    orders = OrderRepositoryImpl(OrderDao(db));
  });

  tearDown(() => db.close());

  Future<int> field(String name,
          {OrderFieldType type = OrderFieldType.text,
          List<String> options = const []}) async =>
      ok(await fields
          .createField(OrderField(name: name, type: type, options: options)));

  Future<int> order({Map<int, String> values = const {}}) async {
    final product = await db
        .into(db.products)
        .insert(ProductsCompanion.insert(name: 'Tulip', sellPrice: 450));
    return ok(await orders.createOrder(
      customerName: 'Maria',
      orderDate: DateTime(2026, 9, 1),
      shipByDate: DateTime(2026, 9, 3),
      channelId: 1,
      totalSales: 450,
      totalMaterialCost: 50,
      channelFees: 10,
      shippingCost: 0,
      profit: 0,
      items: [
        OrderItemInput(
            productId: product,
            productName: 'Tulip',
            quantity: 1,
            unitPrice: 450)
      ],
      materials: const [],
      fieldValues: values,
    ));
  }

  Future<Map<String, String>> valuesOf(int orderId) async => {
        for (final e in ok(await orders.getOrderFieldValues(orderId)))
          e.field.name: e.value,
      };

  Future<void> update(int id, Map<int, String>? values) async =>
      ok(await orders.updateOrder(
        id: id,
        customerName: 'Maria',
        orderDate: DateTime(2026, 9, 1),
        shipByDate: DateTime(2026, 9, 3),
        channelId: 1,
        totalSales: 450,
        totalMaterialCost: 50,
        channelFees: 10,
        shippingCost: 0,
        profit: 0,
        fieldValues: values,
      ));

  group('definitions', () {
    test('new fields go to the end, with options kept in order', () async {
      await field('Address');
      await field('Wrap',
          type: OrderFieldType.choice, options: ['Kraft', 'Floral']);
      final all = ok(await fields.getFields());
      expect(all.map((f) => f.name), ['Address', 'Wrap']);
      expect(all.map((f) => f.position), [0, 1]);
      expect(all.last.options, ['Kraft', 'Floral']);
      expect(all.first.options, isEmpty);
    });

    test('updateField rewrites name, type and options', () async {
      final id =
          await field('Wrap', type: OrderFieldType.choice, options: ['Kraft']);
      ok(await fields.updateField(
        OrderField(
            id: id,
            name: 'Wrapping',
            type: OrderFieldType.choice,
            options: const ['Kraft', 'None']),
      ));
      final f = ok(await fields.getField(id))!;
      expect(f.name, 'Wrapping');
      expect(f.options, ['Kraft', 'None']);
    });

    test('updateField on a missing id fails', () async {
      final result = await fields.updateField(
          const OrderField(id: 99, name: 'X', type: OrderFieldType.text));
      expect(result, isA<Error<void>>());
    });

    test('counts how many orders use each field', () async {
      final address = await field('Address');
      final size = await field('Size');
      await order(values: {address: 'Cebu'});
      await order(values: {address: 'Pasig', size: 'M'});
      await order();
      final all = ok(await fields.getFields());
      expect({for (final f in all) f.name: f.usageCount},
          {'Address': 2, 'Size': 1});
    });

    test('reorder sets positions in list order', () async {
      final a = await field('A');
      final b = await field('B');
      final c = await field('C');
      ok(await fields.reorder([c, a, b]));
      expect(ok(await fields.getFields()).map((f) => f.name), ['C', 'A', 'B']);
    });

    test('archived fields are left out on request; restoring moves to the end',
        () async {
      final a = await field('A');
      await field('B');
      ok(await fields.setArchived(a, true));
      expect(
          ok(await fields.getFields(includeArchived: false)).map((f) => f.name),
          ['B']);
      expect(
          ok(await fields.getFields()).firstWhere((f) => f.id == a).isArchived,
          isTrue);

      ok(await fields.setArchived(a, false));
      expect(ok(await fields.getFields()).map((f) => f.name), ['B', 'A']);
    });

    test('deleting a field orders use fails', () async {
      final address = await field('Address');
      await order(values: {address: 'Cebu'});
      expect(await fields.deleteField(address), isA<Error<void>>());
    });
  });

  group('order values', () {
    test('createOrder saves values, read back in field order', () async {
      final address = await field('Address');
      final size = await field('Size');
      final id = await order(values: {size: 'M', address: 'Cebu'});
      final entries = ok(await orders.getOrderFieldValues(id));
      expect(entries.map((e) => e.field.name), ['Address', 'Size']);
      expect(entries.map((e) => e.value), ['Cebu', 'M']);
    });

    test('updateOrder replaces the whole set', () async {
      final address = await field('Address');
      final size = await field('Size');
      final id = await order(values: {address: 'Cebu', size: 'M'});
      await update(id, {address: 'Pasig'});
      expect(await valuesOf(id), {'Address': 'Pasig'});
    });

    test('updateOrder without values leaves them alone', () async {
      final address = await field('Address');
      final id = await order(values: {address: 'Cebu'});
      await update(id, null);
      expect(await valuesOf(id), {'Address': 'Cebu'});
    });

    test('values for a field deleted meanwhile are skipped', () async {
      final address = await field('Address');
      final gone = await field('Gone');
      ok(await fields.deleteField(gone));
      final id = await order(values: {address: 'Cebu', gone: 'x'});
      expect(await valuesOf(id), {'Address': 'Cebu'});
    });

    test('archived fields still show on the order', () async {
      final card = await field('Card');
      final id = await order(values: {card: 'Happy birthday'});
      ok(await fields.setArchived(card, true));
      final entry = ok(await orders.getOrderFieldValues(id)).single;
      expect(entry.field.isArchived, isTrue);
      expect(entry.value, 'Happy birthday');
    });

    test('deleteOrder removes its values', () async {
      final address = await field('Address');
      final id = await order(values: {address: 'Cebu'});
      ok(await orders.deleteOrder(id));
      expect(ok(await fields.getFields()).single.usageCount, 0);
    });

    test('a failed create leaves no half-saved order', () async {
      final address = await field('Address');
      // Inserting the item line fails after the order row is written; the
      // transaction must take the order row back out with it.
      await db.customStatement('DROP TABLE order_items');
      final result = await orders.createOrder(
        customerName: 'Maria',
        orderDate: DateTime(2026, 9, 1),
        shipByDate: DateTime(2026, 9, 3),
        channelId: 1,
        totalSales: 450,
        totalMaterialCost: 0,
        channelFees: 0,
        shippingCost: 0,
        profit: 0,
        items: const [
          OrderItemInput(
              productId: 999, productName: 'X', quantity: 1, unitPrice: 1)
        ],
        materials: const [],
        fieldValues: {address: 'Cebu'},
      );
      expect(result, isA<Error<int>>());
      expect(ok(await orders.getOrdersByStatus(OrderStatus.pending)), isEmpty);
    });
  });
}
