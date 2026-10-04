import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/utils/note_codec.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/domain/order_field_codec.dart';
import 'package:craftbook/features/order_fields/domain/repositories/order_field_repository.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/create_order.dart';
import 'package:craftbook/features/orders/domain/usecases/pack_order.dart';
import 'package:craftbook/features/orders/domain/usecases/ship_order.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:drift/drift.dart' hide isNull;

T _ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Fills a fresh database with a small craft shop: channels, materials,
/// products with BOMs, order fields, and orders in every status spread over
/// recent days.
/// Requires [configureDependencies] to have run.
Future<void> seedSampleShop() async {
  final channels = getIt<ChannelRepository>();
  final materials = getIt<MaterialRepository>();
  final products = getIt<ProductRepository>();
  final db = getIt<AppDatabase>();
  final fields = getIt<OrderFieldRepository>();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 10);

  final addressField = _ok(await fields.createField(
      const OrderField(name: 'Address', type: OrderFieldType.text, isMultiline: true)));
  final wrapField = _ok(await fields.createField(const OrderField(
      name: 'Wrap', type: OrderFieldType.choice, options: ['Kraft', 'Floral', 'None'])));
  final eventField = _ok(await fields.createField(
      const OrderField(name: 'Event date', type: OrderFieldType.date)));
  // Archived once orders have used it, so its value still shows on them.
  final cardField = _ok(await fields.createField(
      const OrderField(name: 'Card message', type: OrderFieldType.text)));

  final shopee = _ok(await channels.createChannel(
      name: 'Shopee', commissionRate: 8, transactionFeeRate: 2, flatFee: 5, shippingPaidByUs: 40));
  final tiktok = _ok(await channels.createChannel(
      name: 'TikTok Shop', commissionRate: 6, transactionFeeRate: 2, flatFee: 0, shippingPaidByUs: 30));
  final walkIn = _ok(await channels.createChannel(
      name: 'Walk-in', commissionRate: 0, transactionFeeRate: 0, flatFee: 0, shippingPaidByUs: 0));
  final lazada = _ok(await channels.createChannel(
      name: 'Lazada', commissionRate: 10, transactionFeeRate: 2, flatFee: 0, shippingPaidByUs: 0));
  await channels.updateChannel(id: lazada, isActive: false);

  Future<int> material(String name, int pack, double price, int onHand, int alert, [String? supplier]) async =>
      _ok(await materials.createMaterial(
        name: name,
        packSize: pack,
        packPrice: price,
        unitCost: price / pack,
        quantityOnHand: onHand,
        alertLevel: alert,
        supplier: supplier,
      ));

  final yarn = await material('Milk cotton yarn, cream', 10, 180, 40, 8, 'YarnPH');
  final wire = await material('Floral wire 18g', 20, 80, 80, 15);
  final wrap = await material('Cellophane wrap', 10, 260, 14, 5);
  final beads = await material('Glass seed beads 2mm', 50, 120, 16, 10, 'Divisoria Beads');
  final rings = await material('Jump rings 6mm', 100, 80, 48, 20);
  final clasp = await material('Lobster clasp', 50, 150, 12, 10);
  final cord = await material('Phone strap cord', 20, 100, 30, 10);
  final resin = await material('Resin keychain kit', 5, 350, 6, 3);
  await material('Jute cord 4mm', 10, 220, 0, 5);

  Future<int> product(String name, double price, Map<int, int> bom) async {
    final id = _ok(await products.createProduct(name: name, sellPrice: price));
    await products.saveBomItems(id, [
      for (final e in bom.entries) BomItemInput(materialId: e.key, quantityRequired: e.value),
    ]);
    return id;
  }

  final tulip = await product('Crochet tulip bouquet', 450, {yarn: 3, wire: 7, wrap: 1});
  final strap = await product('Beaded phone strap', 180, {beads: 3, rings: 2, clasp: 1, cord: 1});
  final keychain = await product('Resin keychain', 120, {resin: 1, rings: 1});
  final box = _ok(await products.createProduct(
    name: 'Kraft gift box',
    sellPrice: 35,
    isStandalone: true,
    initialQuantity: 6,
    initialUnitCost: 28,
  ));
  await products.updateProduct(id: box, alertLevel: 3);
  _ok(await products.receiveProductStock(productId: box, quantity: 4, pricePerUnit: 26));
  _ok(await products.adjustProductStock(productId: box, newQuantityOnHand: 8));
  // Movements are stamped with the real clock; spread them out so the
  // product history reads like a shop that's been running a while.
  final boxMoves = await (db.select(db.productStockMovements)
        ..where((t) => t.productId.equals(box))
        ..orderBy([(t) => OrderingTerm.asc(t.id)]))
      .get();
  for (final (i, daysAgo) in [30, 15, 8].indexed) {
    await (db.update(db.productStockMovements)..where((t) => t.id.equals(boxMoves[i].id)))
        .write(ProductStockMovementsCompanion(createdAt: Value(today.subtract(Duration(days: daysAgo)))));
  }

  final createOrder = getIt<CreateOrder>();
  final pack = getIt<PackOrder>();
  final ship = getIt<ShipOrder>();
  final orderRepo = getIt<OrderRepository>();

  OrderItemInput item(int id, String name, int qty, double price) =>
      OrderItemInput(productId: id, productName: name, quantity: qty, unitPrice: price);

  Future<int> order(
    String customer,
    int channel,
    List<OrderItemInput> items, {
    required int placedDaysAgo,
    required int shipInDays,
    String address = '',
    Map<int, String> fields = const {},
    String? note,
    double fees = 0,
    double shipping = 0,
  }) async {
    final sales = items.fold<double>(0, (s, i) => s + i.subtotal);
    return _ok(await createOrder(
      customerName: customer,
      fieldValues: {addressField: address, ...fields},
      note: note,
      orderDate: today.subtract(Duration(days: placedDaysAgo)),
      shipByDate: today.add(Duration(days: shipInDays)),
      channelId: channel,
      totalSales: sales,
      channelFees: fees,
      shippingCost: shipping,
      items: items,
    ));
  }

  Future<void> completedOn(int id, DateTime when, {bool shipped = true}) async {
    _ok(await pack(id));
    if (shipped) _ok(await ship(id));
    await (db.update(db.orders)..where((t) => t.id.equals(id))).write(OrdersCompanion(
      packedAt: Value(when),
      shippedAt: Value(shipped ? when : null),
    ));
  }

  // Finished orders across the last few weeks, for Money.
  final history = <(String, int, List<OrderItemInput>, int, double, double)>[
    ('Bea Garcia', shopee, [item(tulip, 'Crochet tulip bouquet', 1, 450)], 20, 50, 40),
    ('Carlo Diaz', tiktok, [item(strap, 'Beaded phone strap', 2, 180)], 12, 29, 30),
    ('Dana Uy', walkIn, [item(keychain, 'Resin keychain', 3, 120)], 9, 0, 0),
    ('Eli Ramos', shopee, [item(tulip, 'Crochet tulip bouquet', 2, 450), item(box, 'Kraft gift box', 1, 35)], 6, 98, 40),
    ('Faye Lim', tiktok, [item(strap, 'Beaded phone strap', 1, 180)], 4, 14, 30),
    ('Gio Tan', walkIn, [item(tulip, 'Crochet tulip bouquet', 1, 450)], 2, 0, 0),
    ('Hana Cruz', shopee, [item(keychain, 'Resin keychain', 2, 120)], 1, 29, 40),
  ];
  for (final (name, ch, items, daysAgo, fees, shipping) in history) {
    final id = await order(name, ch, items,
        placedDaysAgo: daysAgo + 2, shipInDays: -daysAgo, fees: fees, shipping: shipping,
        fields: name == 'Bea Garcia' ? {cardField: 'Happy anniversary, love!'} : const {});
    if (name == 'Eli Ramos') {
      // Used more yarn than planned: shows waste on Money.
      final mats = _ok(await orderRepo.getOrderMaterials(id));
      await orderRepo.adjustMaterialsUsed(id, [
        for (final m in mats)
          OrderMaterialInput(
            materialId: m.materialId,
            materialName: m.materialName,
            plannedQuantity: m.plannedQuantity,
            actualQuantity: m.materialId == yarn ? m.plannedQuantity + 2 : m.actualQuantity,
            wasteQuantity: m.materialId == yarn ? 2 : 0,
            wasteReason: m.materialId == yarn ? 'Cutting' : null,
            unitCost: m.unitCost,
          ),
      ]);
    }
    await completedOn(id, today.subtract(Duration(days: daysAgo)));
  }

  // Open orders for Today and Orders.
  await order('Maria Santos', shopee, [item(tulip, 'Crochet tulip bouquet', 2, 450), item(box, 'Kraft gift box', 1, 35)],
      placedDaysAgo: 3, shipInDays: -1, address: '22 Rizal Ave, Pasig City',
      fields: {
        wrapField: 'Floral',
        eventField: OrderFieldCodec.encodeDate(today.add(const Duration(days: 4))),
      },
      note: 'Gift wrap please, birthday on the 5th', fees: 98.5, shipping: 40);
  await order('Jun Reyes', tiktok, [item(strap, 'Beaded phone strap', 3, 180)],
      placedDaysAgo: 2, shipInDays: 0, address: '9 Kalayaan St, Makati', fees: 43.2, shipping: 30);
  // A formatted note. Maria's above is still plain text, so the screenshots
  // cover both a rich note and one written before rich notes existed.
  final anaNote = NoteCodec.encode(Delta()
    ..insert('Hand-delivered — ')
    ..insert('do not ship', {'bold': true})
    ..insert('\n')
    ..insert('Include the care card\n', {'list': 'unchecked'})
    ..insert('Ring the bell twice\n', {'list': 'checked'}))!;
  final ana = await order('Ana Cruz', walkIn, [item(keychain, 'Resin keychain', 1, 120)],
      placedDaysAgo: 4, shipInDays: 0, note: anaNote);
  await completedOn(ana, today, shipped: false);
  await order('Lea Bautista', shopee, [item(keychain, 'Resin keychain', 1, 120), item(tulip, 'Crochet tulip bouquet', 1, 450)],
      placedDaysAgo: 0, shipInDays: 3, address: '41 Aguinaldo Hwy, Imus', fees: 62, shipping: 40,
      fields: {wrapField: 'Kraft'});
  await order('Paolo Lim', tiktok, [item(strap, 'Beaded phone strap', 2, 180)],
      placedDaysAgo: 0, shipInDays: 5, address: '14 Mabini St, Cubao, Quezon City', fees: 28.8, shipping: 30);

  _ok(await fields.setArchived(cardField, true));
}
