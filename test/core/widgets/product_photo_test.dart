import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/widgets/product_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/sample_photo.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ProductPhoto', () {
    testWidgets('shows the initial when there is no photo', (tester) async {
      await tester.pumpWidget(
          _wrap(const ProductPhoto(bytes: null, name: 'tulip bouquet')));
      expect(find.text('T'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('falls back to an icon for a blank name', (tester) async {
      await tester
          .pumpWidget(_wrap(const ProductPhoto(bytes: null, name: '  ')));
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('shows the photo at the given size', (tester) async {
      await tester.pumpWidget(
          _wrap(ProductPhoto(bytes: tinyPng, name: 'Tulip', size: 56)));
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('T'), findsNothing);
      expect(tester.getSize(find.byType(ProductPhoto)), const Size(56, 56));
    });

    testWidgets('only a real photo responds to taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProductPhoto(bytes: null, name: 'Strap', onTap: () => taps++),
          ProductPhoto(bytes: tinyPng, name: 'Tulip', onTap: () => taps++),
        ],
      )));
      await tester.tap(find.text('S'));
      expect(taps, 0);
      await tester.tap(find.byType(Image));
      expect(taps, 1);
    });
  });

  testWidgets('showPhotoViewer opens full screen and closes', (tester) async {
    await tester.pumpWidget(_wrap(Builder(
      builder: (context) => TextButton(
        onPressed: () =>
            showPhotoViewer(context, bytes: tinyPng, title: 'Tulip bouquet'),
        child: const Text('Open'),
      ),
    )));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('Tulip bouquet'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });
}
