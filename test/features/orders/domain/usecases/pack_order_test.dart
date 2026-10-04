import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/entities/order_product.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/pack_order.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockOrderRepository orders;
  late MockMaterialRepository materials;
  late MockProductRepository products;
  late PackOrder pack;

  setUp(() {
    orders = MockOrderRepository();
    materials = MockMaterialRepository();
    products = MockProductRepository();
    pack = PackOrder(
        orderRepository: orders,
        materialRepository: materials,
        productRepository: products);
    when(() => materials.deductMaterials(any(), any(),
            reserved: any(named: 'reserved')))
        .thenAnswer((_) async => const Success(null));
    when(() => products.deductProductStock(any(), any()))
        .thenAnswer((_) async => const Success(null));
    when(() => orders.packOrder(1))
        .thenAnswer((_) async => const Success(null));
  });

  test('deducts what was used but releases only what was reserved', () async {
    when(() => orders.getOrderMaterials(1)).thenAnswer((_) async => Success([
          OrderMaterial(
            orderId: 1,
            materialId: 10,
            materialName: 'Yarn',
            plannedQuantity: 6,
            actualQuantity: 8,
            wasteQuantity: 2,
            unitCost: 18,
            createdAt: DateTime(2026, 10, 1),
          ),
        ]));
    when(() => orders.getOrderProducts(1))
        .thenAnswer((_) async => const Success([
              OrderProduct(
                  orderId: 1,
                  productId: 5,
                  productName: 'Box',
                  quantity: 1,
                  unitCost: 28),
            ]));

    final result = await pack(1);

    expect(result, const Success<void>(null));
    verify(() => materials.deductMaterials(10, 8, reserved: 6)).called(1);
    verify(() => products.deductProductStock(5, 1)).called(1);
    verify(() => orders.packOrder(1)).called(1);
  });
}
