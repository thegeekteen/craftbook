import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/widgets/app_tag.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:craftbook/features/units/domain/entities/unit_of_measure.dart';
import 'package:craftbook/features/units/domain/repositories/unit_repository.dart';
import 'package:craftbook/features/units/presentation/widgets/unit_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

/// Units of measure end to end: the More row, the list, the menus, and the
/// picker on the material form.
void main() {
  Future<List<UnitOfMeasure>> units() async =>
      ok(await getIt<UnitRepository>().getUnits());

  Future<List<String>> labels() async =>
      (await units()).map((u) => u.label).toList();

  testWidgets('More has a row that names the default unit', (tester) async {
    await startApp(tester);
    await openApp(tester, RouteNames.settings);
    await tester.scrollUntilVisible(find.text('Units of measure'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('8 · new items start on pc'), findsOneWidget);

    await tester.tap(find.text('Units of measure'));
    await settle(tester);
    expect(find.text('pc'), findsOneWidget);
    expect(find.text('DEFAULT'), findsOneWidget);
    expect(find.text('pack'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('adds a unit from the sheet', (tester) async {
    await startApp(tester);
    await openApp(tester, RouteNames.units);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Unit'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'board');
    await tester.tap(find.widgetWithText(FilledButton, 'Add unit'));
    await settle(tester);

    expect(find.text('board added'), findsOneWidget);
    expect(await db<List<String>>(tester, labels), contains('board'));
    await closeApp(tester);
  });

  testWidgets('a duplicate is refused and the list is unchanged',
      (tester) async {
    await startApp(tester);
    await openApp(tester, RouteNames.units);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Unit'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'PC');
    await tester.tap(find.widgetWithText(FilledButton, 'Add unit'));
    await settle(tester);

    expect(
        find.textContaining('already have a unit called "PC"'), findsOneWidget);
    expect(await db<List<String>>(tester, labels), hasLength(8));
    await closeApp(tester);
  });

  testWidgets('the long-press menu makes another unit the default',
      (tester) async {
    await startApp(tester);
    await openApp(tester, RouteNames.units);
    await tester.longPress(find.text('kg'));
    await settle(tester);
    await tester.tap(find.text('Use for new items'));
    await settle(tester);

    expect(find.text('New items start on kg'), findsOneWidget);
    expect(tester.widgetList(find.byType(AppTag)), hasLength(1),
        reason: 'only one unit carries the Default tag');
    await closeApp(tester);
  });

  testWidgets('deletes an unused unit', (tester) async {
    await startApp(tester);
    await openApp(tester, RouteNames.units);
    await tester.longPress(find.text('ml'));
    await settle(tester);
    await tester.tap(find.text('Delete'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    expect(find.text('ml deleted'), findsOneWidget);
    expect(await db<List<String>>(tester, labels), isNot(contains('ml')));
    await closeApp(tester);
  });

  testWidgets('refuses to delete a unit a material is counted in',
      (tester) async {
    await startApp(tester, seed: () async {
      final kg = (await units()).firstWhere((u) => u.label == 'kg');
      ok(await getIt<MaterialRepository>().createMaterial(
        name: 'Glitter',
        unitId: kg.id,
        packSize: 1,
        packPrice: 10,
        unitCost: 10,
        quantityOnHand: 0,
        alertLevel: 0,
      ));
    });
    await openApp(tester, RouteNames.units);
    await tester.longPress(find.text('kg'));
    await settle(tester);
    await tester.tap(find.text('Delete'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    expect(find.textContaining('1 material are counted in it'), findsOneWidget);
    expect(await db<List<String>>(tester, labels), contains('kg'));
    await closeApp(tester);
  });

  testWidgets('the material form picks a unit and saves it', (tester) async {
    await startApp(tester);
    await openApp(tester, RouteNames.materials);
    // Pushed rather than the initial route, so saving can pop back.
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Material'));
    await settle(tester);

    // Starts on the shop's default, and labels the pack field with it.
    expect(find.text('pc'), findsWidgets);
    await tester.tap(find.byType(UnitPickerField));
    await settle(tester);
    await tester.tap(find.text('m').last);
    await settle(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'), 'Cotton cord');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'm per pack'), '10');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Pack price'), '100');
    await tester.tap(find.widgetWithText(FilledButton, 'Add material'));
    await settle(tester);

    final saved = await db<String>(tester, () async {
      final all = ok(await getIt<MaterialRepository>().getAllMaterials());
      return all.single.unit;
    });
    expect(saved, 'm');
    await closeApp(tester);
  });
}
