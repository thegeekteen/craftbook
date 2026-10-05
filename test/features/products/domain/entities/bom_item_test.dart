import 'package:craftbook/features/products/domain/entities/bom_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BomItem line({double qty = 1, double makes = 1, double cost = 3}) => BomItem(
        productId: 1,
        materialId: 1,
        materialName: 'A4 card sheet',
        materialUnitCost: cost,
        quantityRequired: qty,
        makes: makes,
        createdAt: DateTime(2026, 10, 5),
      );

  group('BomItem', () {
    test('defaults to one product per line', () {
      expect(line().makes, 1);
    });

    test('lineCost is the cost of one product', () {
      expect(line(qty: 2).lineCost, 6);
      // One ₱3 sheet makes 9 cards.
      expect(line(makes: 9).lineCost, closeTo(3 / 9, 1e-9));
      expect(line(qty: 2, makes: 3).lineCost, closeTo(2, 1e-9));
    });

    test('piecesFor reserves the exact fraction a line needs', () {
      final sheet = line(makes: 9);
      // A card is a ninth of a sheet, not a whole one.
      expect(sheet.piecesFor(1), closeTo(1 / 9, 1e-3));
      expect(sheet.piecesFor(9), 1);
      expect(sheet.piecesFor(10), closeTo(10 / 9, 1e-3));
      expect(sheet.piecesFor(18), 2);
      expect(sheet.piecesFor(0), 0);
    });

    test('piecesFor with makes 1 is quantity × products', () {
      expect(line(qty: 3).piecesFor(4), 12);
    });

    test('piecesFor with several pieces making several products', () {
      // 2 pieces make 3 products: 4 products need 8/3 pieces.
      expect(line(qty: 2, makes: 3).piecesFor(4), closeTo(8 / 3, 1e-3));
    });

    test('a fractional use is kept as typed', () {
      // A Bubble Head takes 1.25 boards; four of them take five.
      expect(line(qty: 1.25).piecesFor(4), 5);
      expect(line(qty: 1.25).piecesFor(1), 1.25);
    });
  });
}
