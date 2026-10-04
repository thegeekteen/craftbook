import 'dart:convert';

import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/settings/presentation/pages/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBundle extends CachingAssetBundle {
  final String? readme;
  _FakeBundle(this.readme);

  @override
  Future<ByteData> load(String key) async {
    if (readme == null || key != AboutPage.readmeAsset) {
      throw FlutterError('Unable to load asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(readme!)));
  }
}

void main() {
  Future<void> pump(WidgetTester tester, String? readme) => tester.pumpWidget(
        DefaultAssetBundle(
          bundle: _FakeBundle(readme),
          child:
              MaterialApp(theme: AppTheme.lightTheme, home: const AboutPage()),
        ),
      );

  testWidgets('renders the README headings, text and tables', (tester) async {
    await pump(tester,
        '# Craftbook\n\nOffline app.\n\n| Step | Where |\n|---|---|\n| One | More |\n');
    await tester.pumpAndSettle();

    expect(find.text('Craftbook'), findsOneWidget);
    expect(find.text('Offline app.'), findsOneWidget);
    expect(find.text('Step'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('shows a friendly message when the README cannot be loaded',
      (tester) async {
    await pump(tester, null);
    await tester.pumpAndSettle();

    expect(find.textContaining("Couldn't load the guide"), findsOneWidget);
  });
}
