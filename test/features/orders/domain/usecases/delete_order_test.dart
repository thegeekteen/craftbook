import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/entities/order_product.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/delete_order.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late DeleteOrder deleteOrder;
  late MockOrderRepository mockOrderRepo;
  late MockMaterialRepository mockMaterialRepo;

  final pendingOrder = Order(
    id: 1,
    customerName: 'Test',
    customerAddress: 'Addr',
    orderDate: DateTime(2026, 1, 1),
    shipByDate: DateTime(2026, 1, 5),
    status: OrderStatus.pending,
    channelId: 1,
    totalSales: 100,
    totalMaterialCost: 30,
    channelFees: 10,
    shippingCost: 0,
    profit: 60,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final packedOrder = pendingOrder.copyWith(
    id: 2,
    status: OrderStatus.packed,
    packedAt: DateTime(2026, 1, 2),
  );

  final shippedOrder = pendingOrder.copyWith(
    id: 3,
    status: OrderStatus.shipped,
    shippedAt: DateTime(2026, 1, 3),
  );

  final testMaterials = [
    OrderMaterial(
      id: 1,
      orderId: 1,
      materialId: 10,
      materialName: 'Mat A',
      plannedQuantity: 5,
      actualQuantity: 5,
      wasteQuantity: 0,
      unitCost: 2.0,
      createdAt: DateTime(2026, 1, 1),
    ),
    OrderMaterial(
      id: 2,
      orderId: 1,
      materialId: 20,
      materialName: 'Mat B',
      plannedQuantity: 3,
      actualQuantity: 4,
      wasteQuantity: 1,
      unitCost: 5.0,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  late MockProductRepository mockProductRepo;

  setUp(() {
    mockOrderRepo = MockOrderRepository();
    mockMaterialRepo = MockMaterialRepository();
    mockProductRepo = MockProductRepository();
    deleteOrder = DeleteOrder(
      orderRepository: mockOrderRepo,
      materialRepository: mockMaterialRepo,
      productRepository: mockProductRepo,
    );

    when(() => mockOrderRepo.getOrderProducts(any()))
        .thenAnswer((_) async => Success<List<OrderProduct>>(const []));
  });

  group('DeleteOrder', () {
    test('blocks deletion of shipped orders', () async {
      when(() => mockOrderRepo.getOrderById(3))
          .thenAnswer((_) async => Success<Order?>(shippedOrder));

      final result = await deleteOrder(3);

      expect(result, isA<Error>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
        case Success():
          fail('Should return error');
      }
      verifyNever(() => mockOrderRepo.deleteOrder(any()));
    });

    test('deletes pending order and releases reserved materials', () async {
      when(() => mockOrderRepo.getOrderById(1))
          .thenAnswer((_) async => Success<Order?>(pendingOrder));
      when(() => mockOrderRepo.getOrderMaterials(1))
          .thenAnswer(
              (_) async => Success<List<OrderMaterial>>(testMaterials));
      when(() => mockMaterialRepo.releaseReservedMaterials(any(), any()))
          .thenAnswer((_) async => const Success<void>(null));
      when(() => mockOrderRepo.deleteOrder(1))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await deleteOrder(1);

      expect(result, isA<Success>());
      verify(() => mockMaterialRepo.releaseReservedMaterials(10, 5)).called(1);
      verify(() => mockMaterialRepo.releaseReservedMaterials(20, 3)).called(1);
      verify(() => mockOrderRepo.deleteOrder(1)).called(1);
    });

    test('deletes packed order and restores deducted materials', () async {
      when(() => mockOrderRepo.getOrderById(2))
          .thenAnswer((_) async => Success<Order?>(packedOrder));
      when(() => mockOrderRepo.getOrderMaterials(2))
          .thenAnswer(
              (_) async => Success<List<OrderMaterial>>(testMaterials));
      when(() => mockMaterialRepo.restoreDeductedMaterials(any(), any()))
          .thenAnswer((_) async => const Success<void>(null));
      when(() => mockOrderRepo.deleteOrder(2))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await deleteOrder(2);

      expect(result, isA<Success>());
      verify(() => mockMaterialRepo.restoreDeductedMaterials(10, 5)).called(1);
      verify(() => mockMaterialRepo.restoreDeductedMaterials(20, 4)).called(1);
      verify(() => mockOrderRepo.deleteOrder(2)).called(1);
      verifyNever(
          () => mockMaterialRepo.releaseReservedMaterials(any(), any()));
    });

    test('returns failure when order not found', () async {
      when(() => mockOrderRepo.getOrderById(99))
          .thenAnswer((_) async => const Success<Order?>(null));

      final result = await deleteOrder(99);

      expect(result, isA<Error>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<NotFoundFailure>());
        case Success():
          fail('Should return error');
      }
    });
  });
}
