import 'dart:ui' show Tristate;
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/theme/palettes.dart';
import 'package:craftbook/features/settings/domain/entities/order_amount_shown.dart';
import 'package:craftbook/features/settings/domain/repositories/settings_repository.dart';
import 'package:craftbook/features/settings/presentation/bloc/order_amount_cubit.dart';
import 'package:craftbook/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:craftbook/features/settings/presentation/widgets/appearance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late ThemeCubit cubit;
  late OrderAmountCubit amountCubit;
  late _MockSettings repo;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(AppPalette.forest);
    registerFallbackValue(OrderAmountShown.total);
  });

  setUp(() async {
    repo = _MockSettings();
    when(() => repo.setThemeMode(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => repo.setPalette(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => repo.setOrderAmountShown(any()))
        .thenAnswer((_) async => const Success(null));
    cubit = ThemeCubit(repo);
    amountCubit = OrderAmountCubit(repo);
    await getIt.reset();
    getIt.registerSingleton<ThemeCubit>(cubit);
    getIt.registerSingleton<OrderAmountCubit>(amountCubit);
  });
  tearDown(() => getIt.reset());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
            body: SingleChildScrollView(child: AppearanceCard())),
      ));

  testWidgets('shows every colour scheme and the dark mode options',
      (tester) async {
    await pump(tester);
    for (final p in AppPalette.values) {
      expect(find.text(p.label), findsOneWidget);
    }
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('On'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
    expect(find.text('Auto follows your phone'), findsOneWidget);
  });

  testWidgets('marks the current scheme as selected', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    final forest = find.widgetWithText(PaletteSwatch, 'Forest');
    expect(tester.getSemantics(forest).flagsCollection.isSelected,
        Tristate.isTrue);
    final berry = find.widgetWithText(PaletteSwatch, 'Berry');
    expect(tester.getSemantics(berry).flagsCollection.isSelected,
        isNot(Tristate.isTrue));
    handle.dispose();
  });

  testWidgets('tapping a scheme changes the palette only', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Berry'));
    await tester.pump();
    expect(cubit.state.palette, AppPalette.berry);
    expect(cubit.state.mode, ThemeMode.system);
  });

  testWidgets('tapping On, Off and Auto updates the dark mode', (tester) async {
    await pump(tester);
    await tester.tap(find.text('On'));
    await tester.pump();
    expect(cubit.state.mode, ThemeMode.dark);
    expect(find.text('Overrides your phone setting'), findsOneWidget);

    await tester.tap(find.text('Off'));
    await tester.pump();
    expect(cubit.state.mode, ThemeMode.light);

    await tester.tap(find.text('Auto'));
    await tester.pump();
    expect(cubit.state.mode, ThemeMode.system);
    expect(cubit.state.palette, AppPalette.forest);
  });

  testWidgets('order cards show the total by default', (tester) async {
    await pump(tester);
    expect(find.text('Order cards show'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Profit'), findsOneWidget);
    expect(find.text('What the customer pays'), findsOneWidget);
  });

  testWidgets('tapping Profit and Total switches and persists', (tester) async {
    await pump(tester);
    await tester.ensureVisible(find.text('Profit'));
    await tester.tap(find.text('Profit'));
    await tester.pump();
    expect(amountCubit.state, OrderAmountShown.profit);
    expect(find.text('What you keep after costs'), findsOneWidget);
    verify(() => repo.setOrderAmountShown(OrderAmountShown.profit)).called(1);

    await tester.tap(find.text('Total'));
    await tester.pump();
    expect(amountCubit.state, OrderAmountShown.total);
    expect(cubit.state.mode, ThemeMode.system);
  });
}
