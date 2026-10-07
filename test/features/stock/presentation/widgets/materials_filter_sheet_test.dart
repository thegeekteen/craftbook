import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/widgets/choice_chip_row.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/stock/presentation/material_list_filter.dart';
import 'package:craftbook/features/stock/presentation/widgets/materials_filter_sheet.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime(2026, 1, 1);

Material _material(String name,
        {double onHand = 10, double promised = 0, bool archived = false}) =>
    Material(
      name: name,
      packSize: 10,
      packPrice: 100,
      unitCost: 10,
      quantityOnHand: onHand,
      quantityPromised: promised,
      alertLevel: 2,
      isArchived: archived,
      createdAt: _at,
      updatedAt: _at,
    );

void main() {
  Future<MaterialStockFilter?> run(WidgetTester tester, MaterialCatalogueView v,
      Future<void> Function() interact) async {
    MaterialStockFilter? result;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showMaterialsFilterSheet(
              context,
              current: MaterialStockFilter.any,
              view: v),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await interact();
    await tester.pumpAndSettle();
    return result;
  }

  int? count(WidgetTester tester, String label) =>
      tester.widget<AppChip>(find.widgetWithText(AppChip, label)).count;

  final materials = [
    _material('Yarn', promised: 3),
    _material('Glue', onHand: 1),
    _material('Beads'),
  ];

  testWidgets('counts every option and hides Archived when empty',
      (tester) async {
    await run(tester, MaterialCatalogueView(materials: materials), () async {
      expect(find.text('Filter materials'), findsOneWidget);
      expect(count(tester, 'Any'), 3);
      expect(count(tester, 'Low'), 1);
      expect(count(tester, 'Promised'), 1);
      expect(find.widgetWithText(AppChip, 'Archived'), findsNothing);
    });
  });

  testWidgets('picks Archived when something is archived', (tester) async {
    final f = await run(
        tester,
        MaterialCatalogueView(
            materials: [...materials, _material('Old', archived: true)]),
        () async {
      expect(count(tester, 'Archived'), 1);
      await tester.tap(find.widgetWithText(AppChip, 'Archived'));
      await tester.tap(find.text('Show'));
    });
    expect(f, MaterialStockFilter.archived);
  });
}
