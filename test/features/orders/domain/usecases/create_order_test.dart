import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/usecases/create_order.dart';
import 'package:craftbook/features/products/domain/entities/bom_item.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}
class MockProductRepository extends Mock implements ProductRepository {}
class MockMaterialRepository extends Mock implements MaterialRepository {}

void main() {
  late CreateOrder createOrder;
  late MockOrderRepository mockOrderRepo;
  late MockProductRepository mockProductRepo;
  late MockMaterialRepository mockMaterialRepo;

  final bomProduct1 = Product(
    id: 1,
    name: 'Custom Magnets',
    sellPrice: 249.0,
    isActive: true,
    isStandalone: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final bomProduct2 = Product(
    id: 2,
    name: 'Keychain',
    sellPrice: 249.0,
    isActive: true,
    isStandalone: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockOrderRepo = MockOrderRepository();
    mockProductRepo = MockProductRepository();
    mockMaterialRepo = MockMaterialRepository();
    createOrder = CreateOrder(
      orderRepository: mockOrderRepo,
      productRepository: mockProductRepo,
      materialRepository: mockMaterialRepo,
    );

    // Default: all products are BOM-based (not standalone)
    when(() => mockProductRepo.getProductById(1))
        .thenAnswer((_) async => Success<Product?>(bomProduct1));
    when(() => mockProductRepo.getProductById(2))
        .thenAnswer((_) async => Success<Product?>(bomProduct2));
    when(() => mockProductRepo.reserveProductStock(any(), any()))
        .thenAnswer((_) async => const Success<void>(null));
  });

  final testItems = [
    const OrderItemInput(
      productId: 1,
      productName: 'Custom Magnets',
      quantity: 2,
      unitPrice: 249.0,
    ),
  ];

  final testBomItems = [
    BomItem(
      id: 1,
      productId: 1,
      materialId: 1,
      materialName: 'Magnet sheet',
      materialUnitCost: 9.0,
      quantityRequired: 1,
      createdAt: DateTime(2026, 1, 1),
    ),
    BomItem(
      id: 2,
      productId: 1,
      materialId: 2,
      materialName: 'Photo top',
      materialUnitCost: 12.0,
      quantityRequired: 1,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  group('CreateOrder', () {
    test('expands BOM and creates order with correct material cost', () async {
      when(() => mockProductRepo.getBomItems(1))
          .thenAnswer((_) async => Success<List<BomItem>>(testBomItems));

      when(() => mockOrderRepo.createOrder(
            customerName: any(named: 'customerName'),
            customerAddress: any(named: 'customerAddress'),
            note: any(named: 'note'),
            orderDate: any(named: 'orderDate'),
            shipByDate: any(named: 'shipByDate'),
            channelId: any(named: 'channelId'),
            totalSales: any(named: 'totalSales'),
            totalMaterialCost: any(named: 'totalMaterialCost'),
            channelFees: any(named: 'channelFees'),
            shippingCost: any(named: 'shippingCost'),
            profit: any(named: 'profit'),
            items: any(named: 'items'),
            materials: any(named: 'materials'),
            products: any(named: 'products'),
          )).thenAnswer((_) async => const Success<int>(1));

      when(() => mockMaterialRepo.reserveMaterials(any(), any()))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await createOrder(
        customerName: 'Test Customer',
        customerAddress: 'Test Address',
        orderDate: DateTime(2026, 8, 26),
        shipByDate: DateTime(2026, 8, 28),
        channelId: 1,
        totalSales: 498.0,
        channelFees: 39.84,
        shippingCost: 0,
        items: testItems,
      );

      expect(result, const Success<int>(1));

      // Verify BOM was queried for the product
      verify(() => mockProductRepo.getBomItems(1)).called(1);

      // Verify materials were reserved
      verify(() => mockMaterialRepo.reserveMaterials(1, 2)).called(1); // 2 magnet sheets
      verify(() => mockMaterialRepo.reserveMaterials(2, 2)).called(1); // 2 photo tops
    });

    test('returns validation failure for empty customer name', () async {
      final result = await createOrder(
        customerName: '',
        customerAddress: 'Address',
        orderDate: DateTime(2026, 8, 26),
        shipByDate: DateTime(2026, 8, 28),
        channelId: 1,
        totalSales: 100,
        channelFees: 0,
        shippingCost: 0,
        items: testItems,
      );

      expect(result, isA<Error>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
        case Success():
          fail('Should not succeed');
      }
    });

    test('returns validation failure for empty items', () async {
      final result = await createOrder(
        customerName: 'Test',
        customerAddress: 'Address',
        orderDate: DateTime(2026, 8, 26),
        shipByDate: DateTime(2026, 8, 28),
        channelId: 1,
        totalSales: 100,
        channelFees: 0,
        shippingCost: 0,
        items: [],
      );

      expect(result, isA<Error>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
        case Success():
          fail('Should not succeed');
      }
    });

    test('combines materials from multiple items', () async {
      final multiItems = [
        const OrderItemInput(productId: 1, productName: 'Magnets', quantity: 2, unitPrice: 249.0),
        const OrderItemInput(productId: 2, productName: 'Keychain', quantity: 1, unitPrice: 249.0),
      ];

      final keychainBom = [
        BomItem(
          id: 3,
          productId: 2,
          materialId: 1,
          materialName: 'Magnet sheet',
          materialUnitCost: 9.0,
          quantityRequired: 1,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      when(() => mockProductRepo.getBomItems(1))
          .thenAnswer((_) async => Success<List<BomItem>>(testBomItems));
      when(() => mockProductRepo.getBomItems(2))
          .thenAnswer((_) async => Success<List<BomItem>>(keychainBom));

      when(() => mockOrderRepo.createOrder(
            customerName: any(named: 'customerName'),
            customerAddress: any(named: 'customerAddress'),
            note: any(named: 'note'),
            orderDate: any(named: 'orderDate'),
            shipByDate: any(named: 'shipByDate'),
            channelId: any(named: 'channelId'),
            totalSales: any(named: 'totalSales'),
            totalMaterialCost: any(named: 'totalMaterialCost'),
            channelFees: any(named: 'channelFees'),
            shippingCost: any(named: 'shippingCost'),
            profit: any(named: 'profit'),
            items: any(named: 'items'),
            materials: any(named: 'materials'),
            products: any(named: 'products'),
          )).thenAnswer((_) async => const Success<int>(2));

      when(() => mockMaterialRepo.reserveMaterials(any(), any()))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await createOrder(
        customerName: 'Test',
        customerAddress: 'Addr',
        orderDate: DateTime(2026, 8, 26),
        shipByDate: DateTime(2026, 8, 28),
        channelId: 1,
        totalSales: 747.0,
        channelFees: 0,
        shippingCost: 0,
        items: multiItems,
      );

      expect(result, const Success<int>(2));

      // Magnet sheet: 2 (from magnets) + 1 (from keychain) = 3
      verify(() => mockMaterialRepo.reserveMaterials(1, 3)).called(1);
      // Photo top: 2 (from magnets only)
      verify(() => mockMaterialRepo.reserveMaterials(2, 2)).called(1);
    });
  });
}
