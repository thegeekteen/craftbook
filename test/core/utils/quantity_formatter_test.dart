import 'package:craftbook/core/utils/quantity_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Quantities render whole numbers bare and fractions with only the digits
/// they need, and a unit is appended exactly as typed.
void main() {
  group('format', () {
    test('a whole number has no decimals', () {
      expect(QuantityFormatter.format(3), '3');
      expect(QuantityFormatter.format(3.0), '3');
      expect(QuantityFormatter.format(0), '0');
    });

    test('a fraction keeps the digits it needs', () {
      expect(QuantityFormatter.format(1.25), '1.25');
      expect(QuantityFormatter.format(1.5), '1.5');
      expect(QuantityFormatter.format(0.111), '0.111');
    });

    test('trailing zeros are dropped, not padded', () {
      expect(QuantityFormatter.format(1.250), '1.25');
      expect(QuantityFormatter.format(2.000), '2');
    });

    test('beyond three decimals it rounds', () {
      expect(QuantityFormatter.format(1 / 9), '0.111');
      expect(QuantityFormatter.format(0.12345), '0.123');
    });

    test('large counts are not grouped', () {
      // A stock count reads the same as it did before quantities had units.
      expect(QuantityFormatter.format(1234), '1234');
      expect(QuantityFormatter.format(1234.5), '1234.5');
    });

    test('a shortfall keeps its sign', () {
      expect(QuantityFormatter.format(-2), '-2');
      expect(QuantityFormatter.format(-0.25), '-0.25');
    });
  });

  group('withUnit', () {
    test('puts the unit after the number, verbatim', () {
      expect(QuantityFormatter.withUnit(3, 'pc'), '3 pc');
      expect(QuantityFormatter.withUnit(1.25, 'board'), '1.25 board');
      // Never pluralised: "kg" and "m" would be wrong with an "s".
      expect(QuantityFormatter.withUnit(2, 'kg'), '2 kg');
      expect(QuantityFormatter.withUnit(1, 'kg'), '1 kg');
    });

    test('a missing unit gives just the number', () {
      expect(QuantityFormatter.withUnit(3, null), '3');
      expect(QuantityFormatter.withUnit(3, ''), '3');
    });
  });
}
