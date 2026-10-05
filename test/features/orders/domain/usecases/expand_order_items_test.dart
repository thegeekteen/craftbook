import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/usecases/expand_order_items.dart';
import 'package:craftbook/features/products/domain/entities/bom_item.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository products;
  final now = DateTime(2026, 10, 5);

  setUp(() {
    products = MockProductRepository();
    when(() => products.getProductById(any()))
        .thenAnswer((inv) async => Success<Product?>(Product(
              id: inv.positionalArguments.first as int,
              name: 'Cards',
              sellPrice: 3,
              createdAt: now,
              updatedAt: now,
            )));
    // One ₱3 sheet makes 9 cards; each card also takes 1 sleeve.
    when(() => products.getBomItems(1)).thenAnswer((_) async => Success([
          BomItem(
            productId: 1,
            materialId: 10,
            materialName: 'A4 card sheet',
            materialUnitCost: 3,
            quantityRequired: 1,
            makes: 9,
            createdAt: now,
          ),
          BomItem(
            productId: 1,
            materialId: 11,
            materialName: 'Sleeve',
            materialUnitCost: 1,
            quantityRequired: 1,
            createdAt: now,
          ),
        ]));
  });

  Future<ExpandedOrder> expand(int cards) => expandOrderItems(products, [
        OrderItemInput(
            productId: 1, productName: 'Cards', quantity: cards, unitPrice: 3),
      ]);

  test('reserves whole sheets for a line that makes several', () async {
    final ten = await expand(10);
    final sheet = ten.materials.firstWhere((m) => m.materialId == 10);
    expect((sheet.plannedQuantity, sheet.actualQuantity), (2, 2));
    final sleeves = ten.materials.firstWhere((m) => m.materialId == 11);
    expect(sleeves.plannedQuantity, 10);
    expect(ten.totalCost, 2 * 3 + 10 * 1);
  });

  test('a single card still takes a whole sheet', () async {
    final one = await expand(1);
    expect(
        one.materials.firstWhere((m) => m.materialId == 10).plannedQuantity, 1);
  });

  test('nine cards fit on one sheet', () async {
    final nine = await expand(9);
    expect(nine.materials.firstWhere((m) => m.materialId == 10).plannedQuantity,
        1);
  });
}
