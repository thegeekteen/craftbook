import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/entities/order_product.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/restore_order.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late RestoreOrder restoreOrder;
  late MockOrderRepository orderRepo;
  late MockMaterialRepository materialRepo;
  late MockProductRepository productRepo;

  Order order(OrderStatus status) => Order(
        id: 1,
        customerName: 'Ana',
        orderDate: DateTime(2026, 1, 1),
        shipByDate: DateTime(2026, 1, 5),
        status: status,
        channelId: 1,
        totalSales: 100,
        totalMaterialCost: 30,
        channelFees: 10,
        shippingCost: 0,
        profit: 60,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  final materials = [
    OrderMaterial(
      id: 1,
      orderId: 1,
      materialId: 10,
      materialName: 'Beads',
      plannedQuantity: 5,
      actualQuantity: 6,
      wasteQuantity: 1,
      unitCost: 2.0,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  final products = [
    const OrderProduct(
      id: 1,
      orderId: 1,
      productId: 30,
      productName: 'Ready-made pouch',
      quantity: 2,
      unitCost: 4.0,
    ),
  ];

  void stubOrder(OrderStatus status) {
    when(() => orderRepo.getOrderById(1))
        .thenAnswer((_) async => Success<Order?>(order(status)));
  }

  setUp(() {
    orderRepo = MockOrderRepository();
    materialRepo = MockMaterialRepository();
    productRepo = MockProductRepository();
    restoreOrder = RestoreOrder(
      orderRepository: orderRepo,
      materialRepository: materialRepo,
      productRepository: productRepo,
    );

    when(() => orderRepo.getOrderMaterials(1))
        .thenAnswer((_) async => Success<List<OrderMaterial>>(materials));
    when(() => orderRepo.getOrderProducts(1))
        .thenAnswer((_) async => Success<List<OrderProduct>>(products));
    when(() => orderRepo.restoreOrder(1))
        .thenAnswer((_) async => const Success<void>(null));
    when(() => materialRepo.reserveMaterials(any(), any()))
        .thenAnswer((_) async => const Success<void>(null));
    when(() => productRepo.reserveProductStock(any(), any()))
        .thenAnswer((_) async => const Success<void>(null));
  });

  group('RestoreOrder', () {
    test('reserves the planned materials and products again', () async {
      stubOrder(OrderStatus.cancelled);

      final result = await restoreOrder(1);

      expect(result, const Success<void>(null));
      // Planned, not actual: the order goes back to to pack.
      verify(() => materialRepo.reserveMaterials(10, 5)).called(1);
      verify(() => productRepo.reserveProductStock(30, 2)).called(1);
      verify(() => orderRepo.restoreOrder(1)).called(1);
    });

    for (final status in [
      OrderStatus.pending,
      OrderStatus.packed,
      OrderStatus.shipped,
    ]) {
      test('refuses a ${status.name} order and touches nothing', () async {
        stubOrder(status);

        final result = await restoreOrder(1);

        expect(
            result,
            const Error<void>(
                ValidationFailure('Only cancelled orders can be restored')));
        verifyNever(() => materialRepo.reserveMaterials(any(), any()));
        verifyNever(() => orderRepo.restoreOrder(any()));
      });
    }

    test('returns NotFoundFailure for a missing order', () async {
      when(() => orderRepo.getOrderById(1))
          .thenAnswer((_) async => const Success<Order?>(null));

      final result = await restoreOrder(1);

      expect(result, const Error<void>(NotFoundFailure('Order not found')));
    });

    test('stops before restoring when a reservation fails', () async {
      stubOrder(OrderStatus.cancelled);
      when(() => materialRepo.reserveMaterials(any(), any())).thenAnswer(
          (_) async => const Error<void>(DatabaseFailure('disk full')));

      final result = await restoreOrder(1);

      expect(result, const Error<void>(DatabaseFailure('disk full')));
      verifyNever(() => orderRepo.restoreOrder(any()));
    });

    test('passes on a failed lookup', () async {
      when(() => orderRepo.getOrderById(1)).thenAnswer(
          (_) async => const Error<Order?>(DatabaseFailure('locked')));

      final result = await restoreOrder(1);

      expect(result, const Error<void>(DatabaseFailure('locked')));
    });
  });
}
