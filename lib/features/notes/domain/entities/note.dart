import 'package:equatable/equatable.dart';

import '../../../../core/utils/note_codec.dart';

/// A page in the shop's notebook. [body] is Quill Delta JSON, read through
/// [NoteCodec].
class Note extends Equatable {
  final int? id;
  final String title;
  final String? body;

  /// Pinned notes sort first and show on Today.
  final bool isPinned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Note({
    this.id,
    this.title = '',
    this.body,
    this.isPinned = false,
    this.createdAt,
    this.updatedAt,
  });

  /// The body as one line of plain text.
  String get preview => NoteCodec.plainText(body);

  /// The title, or else the body's first line, so an untitled note still has
  /// something to be found by in a list.
  String get displayTitle => titleOr('Untitled');

  /// [displayTitle] with the placeholder for a note with no words, so the
  /// presentation layer can supply the translated one.
  String titleOr(String untitled) {
    if (title.trim().isNotEmpty) return title.trim();
    final firstLine = NoteCodec.textOf(NoteCodec.decode(body))
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => '');
    return firstLine.isEmpty ? untitled : firstLine;
  }

  /// Ticked and total to-do lines. Both are 0 when the note has no checklist.
  ({int done, int total}) get checklist {
    var done = 0;
    var total = 0;
    for (final op in NoteCodec.decode(body).toList()) {
      // Line formats sit on the newline that ends the line.
      if (op.data case final String text) {
        final list = op.attributes?['list'];
        if (list != 'checked' && list != 'unchecked') continue;
        final lines = '\n'.allMatches(text).length;
        total += lines;
        if (list == 'checked') done += lines;
      }
    }
    return (done: done, total: total);
  }

  /// Case-insensitive match against the title and every word of the body.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) || preview.toLowerCase().contains(q);
  }

  Note copyWith({
    int? id,
    String? title,
    String? Function()? body,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body != null ? body() : this.body,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, body, isPinned, createdAt, updatedAt];
}
