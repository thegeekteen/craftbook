import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/orders/domain/entities/order_discount.dart';
import 'package:craftbook/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:craftbook/features/settings/domain/entities/tax_settings.dart';
import 'package:craftbook/features/settings/presentation/bloc/tax_settings_cubit.dart';
import 'package:craftbook/features/settings/presentation/widgets/tax_sheet.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaxSettings', () {
    test('a new order gets tax only when it is on with a rate', () {
      expect(const TaxSettings().forNewOrder, isNull);
      expect(const TaxSettings(enabled: true, rate: 0).forNewOrder, isNull);
      expect(
          const TaxSettings(enabled: true, rate: 12, inclusive: false)
              .forNewOrder,
          const OrderTax(rate: 12, inclusive: false));
    });

    test('off by default: offered, but new orders start without it', () {
      const s = TaxSettings(enabled: true, onByDefault: false);
      expect(s.forNewOrder, isNull);
      expect(s.available, const OrderTax(rate: 12, inclusive: true));
      expect(const TaxSettings(onByDefault: false).available, isNull);
    });
  });

  group('repository', () {
    late AppDatabase db;
    late SettingsRepositoryImpl repo;
    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = SettingsRepositoryImpl(db);
    });
    tearDown(() => db.close());

    test('defaults to off, 12% VAT in prices', () async {
      expect(await repo.getTaxSettings(), const TaxSettings());
    });

    test('round-trips every field', () async {
      const gst = TaxSettings(
          enabled: true,
          onByDefault: false,
          rate: 7.5,
          inclusive: false,
          label: 'GST');
      expect(await repo.setTaxSettings(gst), isA<Success<void>>());
      expect(await repo.getTaxSettings(), gst);
    });

    test('a nonsense rate falls back to the default', () async {
      await db.into(db.settings).insert(SettingsCompanion.insert(
          key: SettingsRepositoryImpl.taxRateKey, value: '250'));
      expect((await repo.getTaxSettings()).rate, 12);
    });
  });

  group('TaxSettingsCubit', () {
    late AppDatabase db;
    late SettingsRepositoryImpl repo;
    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = SettingsRepositoryImpl(db);
    });
    tearDown(() => db.close());

    const on = TaxSettings(enabled: true);

    blocTest<TaxSettingsCubit, TaxSettings>(
      'set emits and persists',
      build: () => TaxSettingsCubit(repo),
      act: (c) => c.set(on),
      expect: () => [on],
      verify: (_) async => expect(await repo.getTaxSettings(), on),
    );

    blocTest<TaxSettingsCubit, TaxSettings>(
      'load emits what was stored',
      setUp: () => repo.setTaxSettings(on),
      build: () => TaxSettingsCubit(repo),
      act: (c) => c.load(),
      expect: () => [on],
    );
  });

  group('tax sheet', () {
    Future<TaxSettings?> run(WidgetTester tester, TaxSettings current,
        Future<void> Function() interact) async {
      TaxSettings? result;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await showTaxSheet(context, current: current),
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

    testWidgets('turns tax on as added on top', (tester) async {
      final result = await run(tester, const TaxSettings(), () async {
        await tester.tap(find.text('Use tax'));
        await tester.tap(find.text('Tax added on top'));
        await tester.pump();
        expect(find.textContaining('₱1,120.00'), findsOneWidget);
        await tester.ensureVisible(find.text('Save'));
        await tester.tap(find.text('Save'));
      });
      expect(
          result, const TaxSettings(enabled: true, rate: 12, inclusive: false));
    });

    testWidgets('new orders can start without tax', (tester) async {
      final result =
          await run(tester, const TaxSettings(enabled: true), () async {
        await tester.tap(find.text('New orders start with tax'));
        await tester.pump();
        expect(find.textContaining('official receipt'), findsOneWidget);
        await tester.ensureVisible(find.text('Save'));
        await tester.tap(find.text('Save'));
      });
      expect(result?.enabled, isTrue);
      expect(result?.onByDefault, isFalse);
    });

    testWidgets('the start choice hides while tax is off', (tester) async {
      await run(tester, const TaxSettings(), () async {
        expect(find.text('New orders start with tax'), findsNothing);
      });
    });

    testWidgets('a zero rate saves as off', (tester) async {
      final result =
          await run(tester, const TaxSettings(enabled: true), () async {
        await tester.enterText(find.widgetWithText(TextField, 'Rate'), '0');
        await tester.ensureVisible(find.text('Save'));
        await tester.tap(find.text('Save'));
      });
      expect(result?.enabled, isFalse);
    });

    testWidgets('explains included tax with the label', (tester) async {
      await run(tester, const TaxSettings(), () async {
        await tester.enterText(find.widgetWithText(TextField, 'Called'), 'GST');
        await tester.pump();
        expect(find.textContaining('₱120.00 GST'), findsOneWidget);
      });
    });
  });
}
