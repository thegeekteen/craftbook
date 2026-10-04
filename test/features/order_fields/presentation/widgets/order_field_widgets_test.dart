import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/presentation/widgets/order_field_input.dart';
import 'package:craftbook/features/order_fields/presentation/widgets/order_field_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  group('OrderFieldInput', () {
    Future<List<String>> pump(
      WidgetTester tester,
      OrderField field, {
      String? value,
      bool enabled = true,
    }) async {
      final emitted = <String>[];
      await tester.pumpWidget(_wrap(Form(
        child: OrderFieldInput(
            field: field,
            value: value,
            enabled: enabled,
            onChanged: emitted.add),
      )));
      return emitted;
    }

    testWidgets('text: labelled box that sends the trimmed text',
        (tester) async {
      const field = OrderField(
          id: 1, name: 'Address', type: OrderFieldType.text, isMultiline: true);
      final emitted = await pump(tester, field, value: 'Cebu');
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Cebu'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), ' 22 Rizal Ave ');
      expect(emitted.last, '22 Rizal Ave');
      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 4);
    });

    testWidgets('text: disabled when the order is locked', (tester) async {
      const field =
          OrderField(id: 1, name: 'Address', type: OrderFieldType.text);
      await pump(tester, field, enabled: false);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('number: sends the stored form and flags bad input',
        (tester) async {
      const field =
          OrderField(id: 2, name: 'Ring size', type: OrderFieldType.number);
      final emitted = await pump(tester, field);
      await tester.enterText(find.byType(TextFormField), '7.50');
      expect(emitted.last, '7.5');
      await tester.enterText(find.byType(TextFormField), '-');
      final form = tester.state<FormState>(find.byType(Form));
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter a number'), findsOneWidget);
    });

    testWidgets('date: shows the stored date and can clear it', (tester) async {
      const field =
          OrderField(id: 3, name: 'Event date', type: OrderFieldType.date);
      final emitted = await pump(tester, field, value: '2024-03-05');
      expect(find.text('Mar 5, 2024'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear Event date'));
      expect(emitted, ['']);
    });

    testWidgets('date: empty shows the placeholder', (tester) async {
      const field =
          OrderField(id: 3, name: 'Event date', type: OrderFieldType.date);
      await pump(tester, field);
      expect(find.text('Not set'), findsOneWidget);
    });

    testWidgets('choice: picks, and tapping the pick again clears it',
        (tester) async {
      const field = OrderField(
          id: 4,
          name: 'Wrap',
          type: OrderFieldType.choice,
          options: ['Kraft', 'Floral']);
      var emitted = await pump(tester, field);
      expect(find.text('WRAP'), findsOneWidget);
      await tester.tap(find.text('Floral'));
      expect(emitted, ['Floral']);

      emitted = await pump(tester, field, value: 'Floral');
      await tester.tap(find.text('Floral'));
      expect(emitted, ['']);
    });

    testWidgets('choice: keeps a stored value whose option was removed',
        (tester) async {
      const field = OrderField(
          id: 4, name: 'Wrap', type: OrderFieldType.choice, options: ['Kraft']);
      await pump(tester, field, value: 'Gold foil');
      expect(find.text('Gold foil'), findsOneWidget);
      expect(find.text('Kraft'), findsOneWidget);
    });
  });

  group('OrderFieldTile', () {
    testWidgets('shows name, type and usage', (tester) async {
      await tester.pumpWidget(_wrap(const OrderFieldTile(
        field: OrderField(
            name: 'Address',
            type: OrderFieldType.text,
            isMultiline: true,
            usageCount: 4),
      )));
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      expect(find.text('Multi-line · used on 4 orders'), findsOneWidget);
    });

    test('describe counts choices and unused fields', () {
      expect(
        OrderFieldTile.describe(const OrderField(
          name: 'Wrap',
          type: OrderFieldType.choice,
          options: ['A', 'B', 'C'],
        )),
        '3 choices · not used yet',
      );
      expect(
        OrderFieldTile.describe(const OrderField(
            name: 'Size', type: OrderFieldType.number, usageCount: 1)),
        'Used on 1 order',
      );
    });

    testWidgets('taps through', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(OrderFieldTile(
        field: const OrderField(name: 'Size', type: OrderFieldType.text),
        onTap: () => taps++,
      )));
      await tester.tap(find.text('Size'));
      expect(taps, 1);
    });
  });
}
