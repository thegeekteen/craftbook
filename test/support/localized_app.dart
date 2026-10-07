import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:craftbook/l10n/gen/app_localizations.dart';

/// A bare [MaterialApp] with the app's localisation delegates, for widget
/// tests that pump a single widget. English unless [locale] says otherwise.
Widget localizedApp(
  Widget home, {
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) =>
    MaterialApp(
      theme: theme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: home,
    );
