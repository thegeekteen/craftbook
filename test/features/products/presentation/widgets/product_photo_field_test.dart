import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/services/photo_picker.dart';
import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/products/presentation/widgets/product_photo_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/sample_photo.dart';

class MockPhotoPicker extends Mock implements PhotoPicker {}

void main() {
  late MockPhotoPicker picker;
  late List<Uint8List?> changes;

  setUpAll(() => registerFallbackValue(PhotoSource.gallery));

  setUp(() async {
    await getIt.reset();
    picker = MockPhotoPicker();
    getIt.registerSingleton<PhotoPicker>(picker);
    changes = [];
  });

  tearDown(getIt.reset);

  Future<void> pump(WidgetTester tester, {Uint8List? photo}) =>
      tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ProductPhotoField(
            photo: photo,
            name: 'Tulip',
            onChanged: changes.add,
          ),
        ),
      ));

  testWidgets('without a photo offers camera and gallery only', (tester) async {
    await pump(tester);
    expect(find.text('Add photo'), findsOneWidget);
    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
    expect(find.text('Remove photo'), findsNothing);
  });

  testWidgets('a gallery pick is handed back', (tester) async {
    when(() => picker.pick(PhotoSource.gallery))
        .thenAnswer((_) async => tinyPng);
    await pump(tester);
    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();
    expect(changes, [tinyPng]);
  });

  testWidgets('backing out of the camera changes nothing', (tester) async {
    when(() => picker.pick(PhotoSource.camera)).thenAnswer((_) async => null);
    await pump(tester);
    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    verify(() => picker.pick(PhotoSource.camera)).called(1);
    expect(changes, isEmpty);
  });

  testWidgets('a camera that fails to open says so', (tester) async {
    when(() => picker.pick(PhotoSource.camera))
        .thenThrow(PlatformException(code: 'camera_access_denied'));
    await pump(tester);
    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't open the camera"), findsOneWidget);
    expect(changes, isEmpty);
  });

  testWidgets('with a photo it can be removed', (tester) async {
    await pump(tester, photo: tinyPng);
    expect(find.text('Change photo'), findsOneWidget);
    await tester.tap(find.text('Change photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove photo'));
    await tester.pumpAndSettle();
    expect(changes, [null]);
    verifyNever(() => picker.pick(any()));
  });
}
