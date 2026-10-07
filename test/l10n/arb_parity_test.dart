import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

/// `{name}` placeholders in a message; a `{` right after a word is an ICU
/// plural/select branch (`other{...}`), whose text is translated, not a name.
Set<String> _placeholders(String message) => RegExp(r'(?<!\w)\{(\w+)(?=[,}])')
    .allMatches(message)
    .map((m) => m[1]!)
    .toSet();

void main() {
  final en = _load('en');
  final fil = _load('fil');
  final keys = en.keys.where((k) => !k.startsWith('@'));

  test('Filipino has every English key and nothing extra', () {
    final filKeys = fil.keys.where((k) => !k.startsWith('@'));
    expect(keys.toSet().difference(filKeys.toSet()), isEmpty,
        reason: 'missing from app_fil.arb');
    expect(filKeys.toSet().difference(keys.toSet()), isEmpty,
        reason: 'not in app_en.arb');
  });

  test('translations only use placeholders English defines', () {
    for (final key in keys.where((k) => fil.containsKey(k))) {
      expect(
          _placeholders(en[key] as String)
              .containsAll(_placeholders(fil[key] as String)),
          isTrue,
          reason: '$key uses a placeholder English does not have');
    }
  });

  test('no translation is empty', () {
    for (final key in keys) {
      expect((fil[key] as String).trim(), isNotEmpty, reason: key);
    }
  });

  test('every key is used by the app', () {
    final source = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
            (f) => f.path.endsWith('.dart') && !f.path.startsWith('lib/l10n/'))
        .map((f) => f.readAsStringSync())
        .join('\n');
    final unused = keys.where((k) => !RegExp('\\b$k\\b').hasMatch(source));
    expect(unused, isEmpty, reason: 'delete these from both ARB files');
  });

  test('messages use typographic apostrophes', () {
    // A straight quote is ICU escape syntax and silently eats text.
    for (final arb in [en, fil]) {
      for (final key in keys) {
        expect((arb[key] as String).contains("'"), isFalse, reason: key);
      }
    }
  });

  test('Filipino plurals use `other` only', () {
    // CLDR puts 0, 1, 2 and 3 in `fil`'s "one" category and gen-l10n maps =1
    // to it, so "=1{…}" would print the singular for 2 or 3 items.
    for (final key in keys) {
      expect((fil[key] as String).contains('=1{'), isFalse, reason: key);
    }
  });
}
