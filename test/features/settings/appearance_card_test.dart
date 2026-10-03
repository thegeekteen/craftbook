import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/settings/domain/repositories/settings_repository.dart';
import 'package:craftbook/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:craftbook/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late ThemeCubit cubit;

  setUpAll(() => registerFallbackValue(ThemeMode.system));

  setUp(() async {
    final repo = _MockSettings();
    when(() => repo.setThemeMode(any())).thenAnswer((_) async => const Success(null));
    cubit = ThemeCubit(repo);
    await getIt.reset();
    getIt.registerSingleton<ThemeCubit>(cubit);
  });
  tearDown(() => getIt.reset());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: AppearanceCard()),
      ));

  testWidgets('shows Auto, On and Off with Auto selected', (tester) async {
    await pump(tester);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('On'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
    expect(find.text('Auto follows your phone'), findsOneWidget);
  });

  testWidgets('tapping On and Off updates the theme', (tester) async {
    await pump(tester);
    await tester.tap(find.text('On'));
    await tester.pump();
    expect(cubit.state, ThemeMode.dark);
    expect(find.text('Overrides your phone setting'), findsOneWidget);

    await tester.tap(find.text('Off'));
    await tester.pump();
    expect(cubit.state, ThemeMode.light);

    await tester.tap(find.text('Auto'));
    await tester.pump();
    expect(cubit.state, ThemeMode.system);
  });
}
