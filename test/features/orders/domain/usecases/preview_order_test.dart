import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/entities/order_product.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/calculate_order_profit.dart';
import 'package:craftbook/features/orders/domain/usecases/preview_order.dart';
import 'package:craftbook/features/products/domain/entities/bom_item.dart';
import 'package:craftbook/features/products/domain/entities/channel.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

class MockChannelRepository extends Mock implements ChannelRepository {}

void main() {
  late MockProductRepository products;
  late MockMaterialRepository materials;
  late MockChannelRepository channels;
  late PreviewOrder preview;
  final now = DateTime(2026, 10, 4);

  Product product(int id,
          {bool standalone = false,
          int onHand = 0,
          int promised = 0,
          double unitCost = 0}) =>
      Product(
        id: id,
        name: 'P$id',
        sellPrice: 100,
        isStandalone: standalone,
        quantityOnHand: onHand,
        quantityPromised: promised,
        unitCost: unitCost,
        createdAt: now,
        updatedAt: now,
      );

  Material material(int id, {required int onHand, int promised = 0}) =>
      Material(
        id: id,
        name: 'M$id',
        packSize: 10,
        packPrice: 100,
        unitCost: 10,
        quantityOnHand: onHand,
        quantityPromised: promised,
        alertLevel: 2,
        createdAt: now,
        updatedAt: now,
      );

  BomItem bom(int productId, int materialId, int qty, double cost) => BomItem(
        productId: productId,
        materialId: materialId,
        materialName: 'M$materialId',
        materialUnitCost: cost,
        quantityRequired: qty,
        createdAt: now,
      );

  setUp(() {
    products = MockProductRepository();
    materials = MockMaterialRepository();
    channels = MockChannelRepository();
    preview = PreviewOrder(
      productRepository: products,
      materialRepository: materials,
      calculateOrderProfit: CalculateOrderProfit(channels),
    );
    when(() => channels.getChannelById(1))
        .thenAnswer((_) async => Success(Channel(
              id: 1,
              name: 'Shop',
              commissionRate: 10,
              transactionFeeRate: 0,
              flatFee: 5,
              shippingPaidByUs: 40,
              isActive: true,
              createdAt: now,
            )));
  });

  test('expands BOM products, merges shared materials and prices fees',
      () async {
    when(() => products.getProductById(1))
        .thenAnswer((_) async => Success(product(1)));
    when(() => products.getProductById(2))
        .thenAnswer((_) async => Success(product(2)));
    when(() => products.getBomItems(1))
        .thenAnswer((_) async => Success([bom(1, 10, 2, 5)]));
    when(() => products.getBomItems(2))
        .thenAnswer((_) async => Success([bom(2, 10, 1, 5), bom(2, 11, 3, 2)]));
    when(() => materials.getMaterialById(10))
        .thenAnswer((_) async => Success(material(10, onHand: 7)));
    when(() => materials.getMaterialById(11)).thenAnswer(
        (_) async => Success(material(11, onHand: 20, promised: 5)));

    final result = await preview(channelId: 1, items: const [
      OrderItemInput(
          productId: 1, productName: 'P1', quantity: 2, unitPrice: 100),
      OrderItemInput(
          productId: 2, productName: 'P2', quantity: 1, unitPrice: 200),
    ]);

    final p = (result as Success<OrderPreview>).value;
    expect(p.sales, 400);
    // M10: 2×2 + 1×1 = 5 pcs at 5; M11: 3 pcs at 2
    expect(p.materialCost, 5 * 5 + 3 * 2);
    expect(p.channelFees, 400 * 0.10 + 5);
    expect(p.shippingCost, 40);
    expect(p.profit, 400 - 31 - 45 - 40);
    expect(p.reservations, [
      const ReservationLine(name: 'M10', quantity: 5, available: 7),
      const ReservationLine(name: 'M11', quantity: 3, available: 15),
    ]);
  });

  test('standalone products reserve their own stock and use unit cost',
      () async {
    when(() => products.getProductById(3)).thenAnswer((_) async => Success(
        product(3, standalone: true, onHand: 2, promised: 1, unitCost: 28)));

    final result = await preview(channelId: 1, items: const [
      OrderItemInput(
          productId: 3, productName: 'P3', quantity: 2, unitPrice: 35),
    ]);

    final p = (result as Success<OrderPreview>).value;
    expect(p.materialCost, 56);
    final line = p.reservations.single;
    expect(line.isProduct, isTrue);
    expect(line.available, 1);
    expect(line.isShort, isTrue);
    verifyNever(() => products.getBomItems(any()));
  });

  test("excludeOrderId counts the order's own reservations as free", () async {
    final orders = MockOrderRepository();
    final editing = PreviewOrder(
      productRepository: products,
      materialRepository: materials,
      calculateOrderProfit: CalculateOrderProfit(channels),
      orderRepository: orders,
    );
    when(() => products.getProductById(1))
        .thenAnswer((_) async => Success(product(1)));
    when(() => products.getProductById(3)).thenAnswer((_) async => Success(
        product(3, standalone: true, onHand: 5, promised: 4, unitCost: 10)));
    when(() => products.getBomItems(1))
        .thenAnswer((_) async => Success([bom(1, 10, 2, 5)]));
    // 10 on hand, 8 promised, of which this order holds 6.
    when(() => materials.getMaterialById(10)).thenAnswer(
        (_) async => Success(material(10, onHand: 10, promised: 8)));
    when(() => orders.getOrderMaterials(7)).thenAnswer((_) async => Success([
          OrderMaterial(
            orderId: 7,
            materialId: 10,
            materialName: 'M10',
            plannedQuantity: 6,
            actualQuantity: 6,
            wasteQuantity: 0,
            unitCost: 5,
            createdAt: now,
          ),
        ]));
    when(() => orders.getOrderProducts(7))
        .thenAnswer((_) async => const Success(<OrderProduct>[
              OrderProduct(
                  orderId: 7,
                  productId: 3,
                  productName: 'P3',
                  quantity: 3,
                  unitCost: 10),
            ]));

    const items = [
      OrderItemInput(
          productId: 1, productName: 'P1', quantity: 3, unitPrice: 100),
      OrderItemInput(
          productId: 3, productName: 'P3', quantity: 3, unitPrice: 100),
    ];
    final plain =
        (await editing(channelId: 1, items: items) as Success<OrderPreview>)
            .value;
    final excluding =
        (await editing(channelId: 1, items: items, excludeOrderId: 7)
                as Success<OrderPreview>)
            .value;

    expect(plain.reservations.every((r) => r.isShort), isTrue,
        reason: 'only 2 pcs / 1 piece look free');
    expect(excluding.reservations.map((r) => r.available), [8, 4]);
    expect(excluding.reservations.any((r) => r.isShort), isFalse);
  });

  test('ReservationLine flags the last piece', () {
    const line = ReservationLine(name: 'x', quantity: 3, available: 3);
    expect(line.usesLast, isTrue);
    expect(line.isShort, isFalse);
    expect(line.remaining, 0);
  });

  test('fails when the channel lookup fails', () async {
    when(() => products.getProductById(1))
        .thenAnswer((_) async => Success(product(1)));
    when(() => products.getBomItems(1))
        .thenAnswer((_) async => const Success([]));
    when(() => channels.getChannelById(9))
        .thenAnswer((_) async => const Error(DatabaseFailure('db')));

    final result = await preview(channelId: 9, items: const [
      OrderItemInput(
          productId: 1, productName: 'P1', quantity: 1, unitPrice: 100),
    ]);

    expect(result, isA<Error<OrderPreview>>());
  });

  test('fails when a product lookup fails', () async {
    when(() => products.getProductById(1))
        .thenAnswer((_) async => const Error(DatabaseFailure('db')));

    final result = await preview(channelId: 1, items: const [
      OrderItemInput(
          productId: 1, productName: 'P1', quantity: 1, unitPrice: 100),
    ]);

    expect(result, isA<Error<OrderPreview>>());
  });
}
