import 'dart:ui' show Locale;

/// The language the app speaks. [system] follows the phone and falls back to
/// English when the phone's language isn't one of ours.
enum AppLanguage {
  system(null),
  en(Locale('en')),
  fil(Locale('fil'));

  /// Null for [system]: MaterialApp then resolves it from the device.
  final Locale? locale;

  const AppLanguage(this.locale);

  static AppLanguage fromName(String? name) =>
      AppLanguage.values.asNameMap()[name] ?? AppLanguage.system;
}
