import 'package:craftbook/core/utils/quantity.dart';
import 'package:flutter_test/flutter_test.dart';

/// The rounding every stored quantity goes through, and the comparison every
/// quantity check uses instead of ==.
void main() {
  group('qty', () {
    test('keeps three decimals', () {
      expect(qty(1.25), 1.25);
      expect(qty(1.2549), 1.255);
      expect(qty(1.2551), 1.255);
    });

    test('a ninth of a sheet is the same every time it is worked out', () {
      // Repeated reserve/release cycles must not drift.
      final one = qty(1 / 9);
      expect(one, 0.111);
      expect(qty(one * 9), 0.999);
      expect(qty(qty(one + one) + one), 0.333);
    });

    test('whole numbers stay whole', () {
      expect(qty(3), 3.0);
      expect(qty(3.0), 3.0);
      expect(qty(0), 0.0);
    });

    test('accepts ints and doubles alike', () {
      expect(qty(2 * 1.25), 2.5);
      expect(qty(5 ~/ 2), 2.0);
    });
  });

  group('sameQty', () {
    test('treats a sub-milli difference as equal', () {
      // Below the precision quantities are kept at, so a float hair from
      // arithmetic doesn't read as a change.
      expect(sameQty(1.0, 1.0004), isTrue);
      expect(sameQty(0.9996, 1.0), isTrue);
    });

    test('tells real differences apart', () {
      expect(sameQty(0.999, 1.0), isFalse);
      expect(sameQty(0, 0.001), isFalse);
      expect(sameQty(1.25, 1.5), isFalse);
    });

    test('zero is zero', () {
      expect(sameQty(0, 0.0), isTrue);
      expect(sameQty(-0.0, 0), isTrue);
    });
  });
}
