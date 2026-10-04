import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/domain/order_field_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalize', () {
    test('trims values and drops blank ones', () {
      expect(
        OrderFieldCodec.normalize({1: '  Cebu ', 2: '', 3: '   ', 4: 'M'}),
        {1: 'Cebu', 4: 'M'},
      );
    });
  });

  group('encodeNumber', () {
    test('stores a canonical decimal', () {
      expect(OrderFieldCodec.encodeNumber('12.50'), '12.5');
      expect(OrderFieldCodec.encodeNumber('007'), '7');
      expect(OrderFieldCodec.encodeNumber('3.0'), '3');
      expect(OrderFieldCodec.encodeNumber(' -2 '), '-2');
    });

    test('rejects text that is not a number', () {
      expect(OrderFieldCodec.encodeNumber('abc'), isNull);
      expect(OrderFieldCodec.encodeNumber('-'), isNull);
      expect(OrderFieldCodec.encodeNumber(''), isNull);
    });
  });

  group('dates', () {
    test('round-trip as yyyy-MM-dd', () {
      final encoded = OrderFieldCodec.encodeDate(DateTime(2026, 10, 4, 15, 30));
      expect(encoded, '2026-10-04');
      expect(OrderFieldCodec.decodeDate(encoded), DateTime(2026, 10, 4));
    });

    test('decode returns null for anything else', () {
      expect(OrderFieldCodec.decodeDate('next week'), isNull);
    });
  });

  group('display', () {
    const date = OrderField(name: 'Event', type: OrderFieldType.date);
    const text = OrderField(name: 'Note', type: OrderFieldType.text);

    test('formats dates for reading', () {
      expect(OrderFieldCodec.display(date, '2026-10-04'), 'Sun, Oct 4, 2026');
    });

    test('shows an unreadable date and other types as stored', () {
      expect(OrderFieldCodec.display(date, 'soon'), 'soon');
      expect(OrderFieldCodec.display(text, '2026-10-04'), '2026-10-04');
    });
  });

  test('an unknown stored type reads as text', () {
    expect(OrderFieldType.fromDb('colour'), OrderFieldType.text);
    expect(OrderFieldType.fromDb('choice'), OrderFieldType.choice);
  });
}
