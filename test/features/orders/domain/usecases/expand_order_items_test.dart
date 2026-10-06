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

  Future<ExpandedOrder> expand(double cards) => expandOrderItems(products, [
        OrderItemInput(
            productId: 1, productName: 'Cards', quantity: cards, unitPrice: 3),
      ]);

  test('a line that makes several reserves the exact fraction', () async {
    final ten = await expand(10);
    final sheet = ten.materials.firstWhere((m) => m.materialId == 10);
    // Ten cards at a ninth of a sheet each.
    expect((sheet.plannedQuantity, sheet.actualQuantity), (1.111, 1.111));
    final sleeves = ten.materials.firstWhere((m) => m.materialId == 11);
    expect(sleeves.plannedQuantity, 10);
    expect(ten.totalCost, closeTo(1.111 * 3 + 10 * 1, 1e-9));
  });

  test('a single card reserves a ninth of a sheet', () async {
    final one = await expand(1);
    expect(
      one.materials.firstWhere((m) => m.materialId == 10).plannedQuantity,
      closeTo(1 / 9, 1e-3),
    );
  });

  test('nine cards use exactly one sheet', () async {
    final nine = await expand(9);
    expect(nine.materials.firstWhere((m) => m.materialId == 10).plannedQuantity,
        1);
  });

  test('a fractional use is reserved as typed', () async {
    // A Bubble Head takes 1.25 boards, so four heads take five.
    when(() => products.getBomItems(2)).thenAnswer((_) async => Success([
          BomItem(
            productId: 2,
            materialId: 20,
            materialName: 'Illustration board',
            materialUnitCost: 40,
            quantityRequired: 1.25,
            createdAt: now,
          ),
        ]));
    final four = await expandOrderItems(products, [
      OrderItemInput(
          productId: 2,
          productName: 'Bubble head',
          quantity: 4,
          unitPrice: 120),
    ]);
    expect(four.materials.single.plannedQuantity, 5);
    expect(four.totalCost, 200);
  });
}
