import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/entities/order_product.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/cancel_order.dart';
import 'package:craftbook/features/orders/domain/usecases/return_order_stock.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late CancelOrder cancelOrder;
  late MockOrderRepository orderRepo;
  late MockMaterialRepository materialRepo;
  late MockProductRepository productRepo;

  const reference = 'Restored from cancelled order';

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
    cancelOrder = CancelOrder(
      orderRepository: orderRepo,
      returnOrderStock: ReturnOrderStock(
        orderRepository: orderRepo,
        materialRepository: materialRepo,
        productRepository: productRepo,
      ),
    );

    when(() => orderRepo.getOrderMaterials(1))
        .thenAnswer((_) async => Success<List<OrderMaterial>>(materials));
    when(() => orderRepo.getOrderProducts(1))
        .thenAnswer((_) async => Success<List<OrderProduct>>(products));
    when(() => orderRepo.cancelOrder(1))
        .thenAnswer((_) async => const Success<void>(null));
    when(() => materialRepo.releaseReservedMaterials(any(), any()))
        .thenAnswer((_) async => const Success<void>(null));
    when(() => materialRepo.restoreDeductedMaterials(any(), any(),
            reference: any(named: 'reference')))
        .thenAnswer((_) async => const Success<void>(null));
    when(() => productRepo.releaseReservedProductStock(any(), any()))
        .thenAnswer((_) async => const Success<void>(null));
    when(() => productRepo.restoreDeductedProductStock(any(), any(),
            reference: any(named: 'reference')))
        .thenAnswer((_) async => const Success<void>(null));
  });

  group('CancelOrder', () {
    test('pending: releases what was reserved, then cancels', () async {
      stubOrder(OrderStatus.pending);

      final result = await cancelOrder(1);

      expect(result, const Success<void>(null));
      verify(() => materialRepo.releaseReservedMaterials(10, 5)).called(1);
      verify(() => productRepo.releaseReservedProductStock(30, 2)).called(1);
      verifyNever(() => materialRepo.restoreDeductedMaterials(any(), any(),
          reference: any(named: 'reference')));
      verify(() => orderRepo.cancelOrder(1)).called(1);
    });

    test('packed: puts what was used back on the shelf, then cancels',
        () async {
      stubOrder(OrderStatus.packed);

      final result = await cancelOrder(1);

      expect(result, const Success<void>(null));
      verify(() => materialRepo.restoreDeductedMaterials(10, 6,
          reference: reference)).called(1);
      verify(() => productRepo.restoreDeductedProductStock(30, 2,
          reference: reference)).called(1);
      verifyNever(() => materialRepo.releaseReservedMaterials(any(), any()));
      verify(() => orderRepo.cancelOrder(1)).called(1);
    });

    test('shipped: puts what was used back on the shelf, then cancels',
        () async {
      stubOrder(OrderStatus.shipped);

      final result = await cancelOrder(1);

      expect(result, const Success<void>(null));
      verify(() => materialRepo.restoreDeductedMaterials(10, 6,
          reference: reference)).called(1);
      verify(() => productRepo.restoreDeductedProductStock(30, 2,
          reference: reference)).called(1);
      verifyNever(() => materialRepo.releaseReservedMaterials(any(), any()));
      verify(() => orderRepo.cancelOrder(1)).called(1);
    });

    test('already cancelled: refuses so stock is not returned twice', () async {
      stubOrder(OrderStatus.cancelled);

      final result = await cancelOrder(1);

      expect(
        result,
        const Error<void>(ValidationFailure('This order is already cancelled')),
      );
      verifyNever(() => orderRepo.getOrderMaterials(any()));
      verifyNever(() => orderRepo.cancelOrder(any()));
    });

    test('missing order: not found', () async {
      when(() => orderRepo.getOrderById(1))
          .thenAnswer((_) async => const Success<Order?>(null));

      final result = await cancelOrder(1);

      expect(result, const Error<void>(NotFoundFailure('Order not found')));
    });

    test('lookup failure is passed through', () async {
      when(() => orderRepo.getOrderById(1)).thenAnswer(
          (_) async => const Error<Order?>(DatabaseFailure('disk full')));

      final result = await cancelOrder(1);

      expect(result, const Error<void>(DatabaseFailure('disk full')));
      verifyNever(() => orderRepo.cancelOrder(any()));
    });
  });
}
