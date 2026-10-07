import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:craftbook/core/widgets/pip_strip.dart';
import 'package:craftbook/core/widgets/status_pill.dart';
import 'package:craftbook/core/widgets/currency_text.dart';
import 'package:craftbook/core/widgets/stepper_input.dart';
import '../../support/localized_app.dart';

void main() {
  group('PipStrip', () {
    testWidgets('renders correct number of pips', (tester) async {
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: PipStrip(total: 10, free: 6, promised: 2),
        )),
      );

      final containers = find.byType(Container);
      expect(containers, findsAtLeastNWidgets(10));
    });

    testWidgets('renders with zero pips', (tester) async {
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: PipStrip(total: 0, free: 0, promised: 0),
        )),
      );

      expect(find.byType(PipStrip), findsOneWidget);
    });
  });

  group('StatusPill', () {
    testWidgets('displays text in uppercase', (tester) async {
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: StatusPill(text: 'ready'),
        )),
      );

      expect(find.text('READY'), findsOneWidget);
    });

    testWidgets('renders with different types', (tester) async {
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: Row(
            children: [
              StatusPill(text: 'OK', type: StatusPillType.success),
              StatusPill(text: 'ERR', type: StatusPillType.alert),
              StatusPill(text: 'WARN', type: StatusPillType.warning),
            ],
          ),
        )),
      );

      expect(find.text('OK'), findsOneWidget);
      expect(find.text('ERR'), findsOneWidget);
      expect(find.text('WARN'), findsOneWidget);
    });
  });

  group('CurrencyText', () {
    testWidgets('displays formatted peso amount', (tester) async {
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: CurrencyText(amount: 1234.56),
        )),
      );

      expect(find.textContaining('1,234.56'), findsOneWidget);
    });

    testWidgets('displays zero correctly', (tester) async {
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: CurrencyText(amount: 0),
        )),
      );

      expect(find.textContaining('0.00'), findsOneWidget);
    });
  });

  group('StepperInput', () {
    testWidgets('displays current value', (tester) async {
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: StepperInput(
            value: 5,
            onChanged: (_) {},
          ),
        )),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('calls onChanged with incremented value', (tester) async {
      int newValue = 0;
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: StepperInput(
            value: 5,
            onChanged: (v) => newValue = v.toInt(),
          ),
        )),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(newValue, 6);
    });

    testWidgets('calls onChanged with decremented value', (tester) async {
      int newValue = 0;
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: StepperInput(
            value: 5,
            onChanged: (v) => newValue = v.toInt(),
          ),
        )),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(newValue, 4);
    });

    testWidgets('respects min value', (tester) async {
      int? changedValue;
      await tester.pumpWidget(
        localizedApp(Scaffold(
          body: StepperInput(
            value: 0,
            min: 0,
            onChanged: (v) => changedValue = v.toInt(),
          ),
        )),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(changedValue, isNull);
    });
  });
}
