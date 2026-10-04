import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/notes_table.dart';

part 'note_dao.g.dart';

/// Data Access Object for the notebook
@DriftAccessor(tables: [Notes])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(super.db);

  /// Pinned first, then the most recently edited.
  Future<List<Note>> getAll() => _ordered(select(notes)).get();

  Future<List<Note>> getPinned() =>
      _ordered(select(notes)..where((t) => t.isPinned.equals(true))).get();

  Future<Note?> getById(int id) =>
      (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);

  /// Writes [note] and stamps it as just edited.
  Future<int> updateNote(int id, NotesCompanion note) {
    return (update(notes)..where((t) => t.id.equals(id)))
        .write(note.copyWith(updatedAt: Value(DateTime.now())));
  }

  /// Pinning is not an edit, so `updatedAt` stays put.
  Future<int> setPinned(int id, bool pinned) {
    return (update(notes)..where((t) => t.id.equals(id)))
        .write(NotesCompanion(isPinned: Value(pinned)));
  }

  Future<int> deleteNote(int id) =>
      (delete(notes)..where((t) => t.id.equals(id))).go();

  SimpleSelectStatement<$NotesTable, Note> _ordered(
    SimpleSelectStatement<$NotesTable, Note> query,
  ) {
    return query
      ..orderBy([
        (t) => OrderingTerm.desc(t.isPinned),
        (t) => OrderingTerm.desc(t.updatedAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
  }
}
