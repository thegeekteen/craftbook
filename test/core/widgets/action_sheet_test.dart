import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/theme/colors.dart';
import 'package:craftbook/core/widgets/action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Pick { edit, delete }

void main() {
  const actions = [
    SheetAction(value: _Pick.edit, icon: Icons.edit_outlined, label: 'Edit'),
    SheetAction(
        value: _Pick.delete,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        destructive: true),
  ];

  /// A button that opens the sheet and records what it returned.
  Future<List<_Pick?>> host(WidgetTester tester) async {
    final picks = <_Pick?>[];
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picks.add(await showActionSheet<_Pick>(
                context,
                title: 'Tulip bouquet',
                subtitle: 'Handmade',
                actions: actions)),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return picks;
  }

  testWidgets('lists the title and every action', (tester) async {
    await host(tester);
    expect(find.text('Tulip bouquet'), findsOneWidget);
    expect(find.text('Handmade'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('tapping an action closes the sheet and returns it',
      (tester) async {
    final picks = await host(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(picks, [_Pick.delete]);
    expect(find.text('Tulip bouquet'), findsNothing);
  });

  testWidgets('dismissing returns null', (tester) async {
    final picks = await host(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(picks, [null]);
  });

  testWidgets('destructive actions use the alert colour', (tester) async {
    await host(tester);
    final alert = tester.element(find.text('Delete')).colors.alert;
    expect(tester.widget<Text>(find.text('Delete')).style?.color, alert);
    expect(tester.widget<Icon>(find.byIcon(Icons.delete_outline_rounded)).color,
        alert);
    expect(tester.widget<Text>(find.text('Edit')).style?.color, isNull);
  });
}
