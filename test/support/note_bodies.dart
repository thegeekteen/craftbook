import 'dart:convert';

/// Delta JSON for a note whose lines are [lines], each a to-do when it starts
/// with "[ ] " or "[x] ".
String noteBody(List<String> lines) {
  final ops = <Map<String, Object?>>[];
  for (final line in lines) {
    final (text, list) = switch (line) {
      _ when line.startsWith('[x] ') => (line.substring(4), 'checked'),
      _ when line.startsWith('[ ] ') => (line.substring(4), 'unchecked'),
      _ => (line, null),
    };
    ops.add({'insert': text});
    ops.add({
      'insert': '\n',
      if (list != null) 'attributes': {'list': list},
    });
  }
  return jsonEncode(ops);
}
