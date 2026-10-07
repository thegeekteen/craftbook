import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/theme/palettes.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:craftbook/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:craftbook/features/settings/domain/entities/app_language.dart';
import 'package:craftbook/features/settings/domain/repositories/settings_repository.dart';
import 'package:craftbook/features/settings/presentation/bloc/language_cubit.dart';
import 'package:craftbook/features/settings/presentation/widgets/language_sheet.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_app.dart';

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  group('LanguageCubit', () {
    late _MockSettings repo;

    setUpAll(() => registerFallbackValue(AppLanguage.system));

    setUp(() {
      repo = _MockSettings();
      when(() => repo.setLanguage(any()))
          .thenAnswer((_) async => const Success(null));
    });

    test('starts on the system language', () {
      expect(LanguageCubit(repo).state, AppLanguage.system);
    });

    blocTest<LanguageCubit, AppLanguage>(
      'load emits the stored language',
      build: () {
        when(() => repo.getLanguage()).thenAnswer((_) async => AppLanguage.fil);
        return LanguageCubit(repo);
      },
      act: (c) => c.load(),
      expect: () => [AppLanguage.fil],
    );

    blocTest<LanguageCubit, AppLanguage>(
      'set emits and persists',
      build: () => LanguageCubit(repo),
      act: (c) => c.set(AppLanguage.en),
      expect: () => [AppLanguage.en],
      verify: (_) => verify(() => repo.setLanguage(AppLanguage.en)).called(1),
    );
  });

  group('settings repository language', () {
    late AppDatabase db;
    late SettingsRepositoryImpl repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = SettingsRepositoryImpl(db);
    });
    tearDown(() => db.close());

    test('defaults to the system language', () async {
      expect(await repo.getLanguage(), AppLanguage.system);
    });

    for (final language in AppLanguage.values) {
      test('round-trips ${language.name}', () async {
        expect(await repo.setLanguage(language), isA<Success<void>>());
        expect(await repo.getLanguage(), language);
      });
    }

    test('an unknown stored value falls back to the system language', () async {
      await db.into(db.settings).insert(SettingsCompanion.insert(
          key: SettingsRepositoryImpl.languageKey, value: 'klingon'));
      expect(await repo.getLanguage(), AppLanguage.system);
    });
  });

  group('language sheet', () {
    Future<AppLanguage?> open(WidgetTester tester,
        {Locale locale = const Locale('en'),
        Future<void> Function()? interact}) async {
      AppLanguage? picked;
      await tester.pumpWidget(localizedApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async => picked =
                  await showLanguageSheet(context, current: AppLanguage.fil),
              child: const Text('open'),
            ),
          ),
          locale: locale,
          theme: AppTheme.light(AppPalette.forest)));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await interact?.call();
      await tester.pumpAndSettle();
      return picked;
    }

    testWidgets('lists three options and marks the current one',
        (tester) async {
      await open(tester, interact: () async {
        expect(find.text('System default'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Filipino (Tagalog)'), findsOneWidget);
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });
    });

    testWidgets('tapping an option returns it', (tester) async {
      final picked =
          await open(tester, interact: () => tester.tap(find.text('English')));
      expect(picked, AppLanguage.en);
    });

    testWidgets('dismissing returns nothing', (tester) async {
      final picked =
          await open(tester, interact: () => tester.tapAt(const Offset(5, 5)));
      expect(picked, isNull);
    });

    testWidgets('is shown in Filipino when the app is', (tester) async {
      await open(tester, locale: const Locale('fil'), interact: () async {
        expect(find.text('Wika'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
      });
    });
  });
}
