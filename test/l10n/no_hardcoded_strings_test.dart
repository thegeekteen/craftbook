import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-scanning guard: user-facing text must come from the ARB files
/// (`context.l10n.*`), not string literals in widgets. Best-effort regex net,
/// not a parser: it looks at literals handed straight to the widgets and named
/// parameters that show text.
///
/// Add to [_allowed] only for text that is genuinely not translatable, with
/// the reason.
const _allowed = <String, String>{
  'lib/features/settings/presentation/widgets/tax_sheet.dart:VAT':
      'Example tax name shown as a hint, the same everywhere',
  'lib/features/social_links/domain/social_url.dart:https://\$text':
      'URL scheme, not text',
};

const _skipDirs = [
  'lib/l10n/',
  'lib/features/debug/',
  'lib/core/factory/',
  'lib/database/',
];

final _widgets = RegExp(
    r'''\b(?:Text|SelectableText)\(\s*(?:const\s+)?(['"])((?:\\.|(?!\1).)*)\1''',
    dotAll: true);
final _params = RegExp(
    r'''\b(?:title|label|hintText|labelText|helperText|tooltip|semanticLabel|subtitle|text|message|content|description|errorText|prefixText|suffixText|child:\s*(?:const\s+)?Text)\s*:\s*(?:const\s+)?(['"])((?:\\.|(?!\1).)*)\1''');

/// Text a person would read: has a letter and is more than an interpolation.
bool _isProse(String literal) {
  // A literal cut short by a nested quote inside `${...}` (e.g. `${a ? '+' : '-'}`):
  // the regex can't see its end, and what it holds is symbols, not prose.
  if ('\${'.allMatches(literal).length > '}'.allMatches(literal).length) {
    return false;
  }
  final stripped = literal.replaceAll(RegExp(r'\$\{[^}]*\}|\$\w+'), '');
  return RegExp(r'[A-Za-z]{2,}').hasMatch(stripped);
}

String _stripComments(String source) => source
    .split('\n')
    .map((l) => l.replaceFirst(RegExp(r'(?<!:)//.*$'), ''))
    .join('\n');

void main() {
  test('no user-facing string literals in lib/', () {
    final offenders = <String>[];
    final used = <String>{};
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .where((f) => !_skipDirs.any(f.path.startsWith));
    for (final file in files) {
      final source = _stripComments(file.readAsStringSync());
      for (final re in [_widgets, _params]) {
        for (final m in re.allMatches(source)) {
          final literal = m[2]!;
          if (!_isProse(literal)) continue;
          final line = '\n'.allMatches(source.substring(0, m.start)).length + 1;
          final key = '${file.path}:$literal';
          if (_allowed.containsKey(key)) {
            used.add(key);
            continue;
          }
          offenders.add('${file.path}:$line  "$literal"');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Move these into lib/l10n/parts/*.arb and use context.l10n:\n'
            '${offenders.join('\n')}');
    expect(_allowed.keys.toSet().difference(used), isEmpty,
        reason: 'stale allowlist entries');
  });
}
