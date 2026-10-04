import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/product_stock_status.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 1, 1);

Product _product({
  bool standalone = false,
  int onHand = 0,
  int promised = 0,
  int alertLevel = 0,
}) =>
    Product(
      id: 1,
      name: 'Tulip',
      sellPrice: 400,
      isStandalone: standalone,
      quantityOnHand: onHand,
      quantityPromised: promised,
      alertLevel: alertLevel,
      createdAt: _now,
      updatedAt: _now,
    );

void main() {
  group('isProductLow handmade', () {
    test('off when no alert level is set', () {
      expect(isProductLow(_product(), 0), isFalse);
      expect(isProductLow(_product(), 1), isFalse);
    });

    test('low at and below the alert level', () {
      expect(isProductLow(_product(alertLevel: 3), 3), isTrue);
      expect(isProductLow(_product(alertLevel: 3), 0), isTrue);
    });

    test('not low above the alert level', () {
      expect(isProductLow(_product(alertLevel: 3), 4), isFalse);
    });

    test('not low when buildable is unknown', () {
      expect(isProductLow(_product(alertLevel: 3), null), isFalse);
    });
  });

  group('isProductLow resell', () {
    test('compares pieces on hand, ignoring buildable', () {
      final p = _product(standalone: true, onHand: 3, alertLevel: 3);
      expect(isProductLow(p, 99), isTrue);
      expect(isProductLow(p, null), isTrue);
    });

    test('off when no alert level is set', () {
      expect(isProductLow(_product(standalone: true), 0), isFalse);
    });

    test('not low above the alert level', () {
      expect(
          isProductLow(_product(standalone: true, onHand: 4, alertLevel: 3), 4),
          isFalse);
    });
  });

  group('isProductShort', () {
    test('resell is short when promised exceeds on hand', () {
      final p = _product(standalone: true, onHand: 2, promised: 3);
      expect(isProductShort(p, rawBuildable: -1, pendingOrders: 0), isTrue);
    });

    test('resell is not short when stock covers promised', () {
      final p = _product(standalone: true, onHand: 3, promised: 3);
      expect(isProductShort(p, rawBuildable: 0, pendingOrders: 2), isFalse);
    });

    test('handmade is short with pending orders and negative buildable', () {
      expect(isProductShort(_product(), rawBuildable: -1, pendingOrders: 1),
          isTrue);
    });

    test('handmade without pending orders is not short', () {
      expect(isProductShort(_product(), rawBuildable: -4, pendingOrders: 0),
          isFalse);
    });

    test('handmade with zero buildable is not short', () {
      expect(isProductShort(_product(), rawBuildable: 0, pendingOrders: 2),
          isFalse);
    });
  });
}
