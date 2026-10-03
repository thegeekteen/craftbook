import 'dart:convert';

import 'package:dart_quill_delta/dart_quill_delta.dart';

/// Converts order notes between the Quill Delta the editor speaks and the
/// string stored in `orders.note`.
///
/// Notes are rich text, but the column is still plain TEXT holding the Delta's
/// JSON, so no schema change or migration was needed. Notes written before rich
/// text existed are plain text: they decode into a single paragraph and only
/// turn into JSON the next time someone saves them.
abstract final class NoteCodec {
  /// Delta JSON for [delta], or null when it holds nothing but whitespace.
  ///
  /// An empty Quill document still serialises to `[{"insert":"\n"}]`, so
  /// blankness has to be judged on the text and not on the string.
  static String? encode(Delta delta) {
    if (textOf(delta).trim().isEmpty) return null;
    return jsonEncode(delta.toJson());
  }

  /// Rebuilds a Delta from a stored note. Never throws: null, blank, legacy
  /// plain text and malformed JSON all come back as an editable document.
  static Delta decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return Delta()..insert('\n');
    if (_tryParseJson(raw) case final List json) {
      try {
        return Delta.fromJson(json);
      } on Object {
        // A list that isn't a Delta; fall through and keep it as text.
      }
    }
    return Delta()..insert('$raw\n');
  }

  /// Everything a document says, ignoring formatting and embeds.
  static String textOf(Delta delta) {
    final buffer = StringBuffer();
    for (final op in delta.toList()) {
      if (op.data case final String text) buffer.write(text);
    }
    return buffer.toString();
  }

  /// One line of plain text for previews, rows and subtitles.
  static String plainText(String? raw) =>
      textOf(decode(raw)).replaceAll('\n', ' ').replaceAll(_runsOfSpace, ' ').trim();

  /// True when there is nothing worth keeping, so callers store null.
  static bool isBlank(String? raw) => textOf(decode(raw)).trim().isEmpty;

  static final RegExp _runsOfSpace = RegExp(r'\s{2,}');

  static Object? _tryParseJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
