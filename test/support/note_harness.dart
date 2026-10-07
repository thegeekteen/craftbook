import 'package:craftbook/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:craftbook/l10n/gen/app_localizations.dart';

/// Quill looks its own strings up through these, so any test that mounts the
/// note editor or its toolbar has to install them.
const List<LocalizationsDelegate<Object?>> noteTestDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  FlutterQuillLocalizations.delegate,
];

/// Mounts [child] in the app theme, the way other widget tests do.
Widget wrapWithTheme(Widget child, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: noteTestDelegates,
      home: Scaffold(body: child),
    );

/// The editor's cursor blinks on a repeating animation, so `pumpAndSettle`
/// would never return. Pump a fixed run of frames instead.
Future<void> settleNote(WidgetTester tester, {int frames = 8}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}
