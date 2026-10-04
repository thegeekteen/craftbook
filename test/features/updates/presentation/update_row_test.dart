import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/updates/domain/entities/app_update.dart';
import 'package:craftbook/features/updates/domain/repositories/update_repository.dart';
import 'package:craftbook/features/updates/domain/usecases/check_for_update.dart';
import 'package:craftbook/features/updates/domain/usecases/install_update.dart';
import 'package:craftbook/features/updates/presentation/bloc/update_cubit.dart';
import 'package:craftbook/features/updates/presentation/widgets/update_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements UpdateRepository {}

class _MockCheck extends Mock implements CheckForUpdate {}

class _MockInstall extends Mock implements InstallUpdate {}

const _update = AppUpdate(
  version: '1.0.5',
  notes: '- Faster order list',
  downloadUrl: 'https://example.com/craftbook-1.0.5.apk',
);

void main() {
  late _MockCheck check;
  late _MockInstall install;
  late UpdateCubit cubit;

  setUpAll(() => registerFallbackValue(_update));

  setUp(() {
    check = _MockCheck();
    install = _MockInstall();
    cubit = UpdateCubit(
      repository: _MockRepo(),
      checkForUpdate: check,
      installUpdate: install,
    );
  });
  tearDown(() => cubit.close());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const UpdateRow()),
        ),
      ));

  testWidgets('starts as a check button', (tester) async {
    await pump(tester);
    expect(find.text('Check for updates'), findsOneWidget);
    expect(find.text('Get the newest version of Craftbook'), findsOneWidget);
  });

  testWidgets('says when there is nothing new', (tester) async {
    when(() => check()).thenAnswer((_) async => const Success(null));
    await pump(tester);
    await tester.tap(find.text('Check for updates'));
    await tester.pumpAndSettle();
    expect(find.text("You're on the newest version"), findsOneWidget);
  });

  testWidgets('shows why a check failed', (tester) async {
    when(() => check()).thenAnswer(
        (_) async => const Error(NetworkFailure('No internet right now')));
    await pump(tester);
    await tester.tap(find.text('Check for updates'));
    await tester.pumpAndSettle();
    expect(find.text('No internet right now'), findsOneWidget);
  });

  testWidgets('offers a found update with its notes and installs on yes',
      (tester) async {
    when(() => check()).thenAnswer((_) async => const Success(_update));
    when(() => install(any(), onProgress: any(named: 'onProgress')))
        .thenAnswer((_) async => const Success(null));
    await pump(tester);
    await tester.tap(find.text('Check for updates'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Faster order list'), findsOneWidget);
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    verify(() => install(_update, onProgress: any(named: 'onProgress')))
        .called(1);
  });

  testWidgets('"Later" keeps the update on the row', (tester) async {
    when(() => check()).thenAnswer((_) async => const Success(_update));
    await pump(tester);
    await tester.tap(find.text('Check for updates'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(find.text('Update to 1.0.5'), findsOneWidget);
    expect(find.text('Tap to download and install'), findsOneWidget);
    verifyNever(() => install(any(), onProgress: any(named: 'onProgress')));
  });
}
