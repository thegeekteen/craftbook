import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart' hide Note;
import 'package:craftbook/database/daos/note_dao.dart';
import 'package:craftbook/features/notes/data/repositories/note_repository_impl.dart';
import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/note_bodies.dart';
import '../../../support/sqlite.dart';

T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// The notebook against a real (in-memory) database.
void main() {
  setUpAll(useHostSqlite);

  late AppDatabase db;
  late NoteRepositoryImpl notes;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    notes = NoteRepositoryImpl(NoteDao(db));
  });

  tearDown(() => db.close());

  /// A note last edited [daysAgo] days back, so ordering is deterministic.
  Future<int> note(String title, {bool pinned = false, int daysAgo = 0}) async {
    final at = DateTime(2026, 10, 1).subtract(Duration(days: daysAgo));
    return db.into(db.notes).insert(NotesCompanion.insert(
          title: Value(title),
          isPinned: Value(pinned),
          createdAt: Value(at),
          updatedAt: Value(at),
        ));
  }

  List<String> titles(List<Note> list) => [for (final n in list) n.title];

  test('creates and reads back a note', () async {
    final body = noteBody(['[ ] Ribbon']);
    final id = ok(await notes.createNote(Note(title: 'Suppliers', body: body, isPinned: true)));

    final saved = ok(await notes.getNote(id))!;
    expect(saved.title, 'Suppliers');
    expect(saved.body, body);
    expect(saved.isPinned, isTrue);
    expect(saved.createdAt, isNotNull);
  });

  test('a missing note reads as null', () async {
    expect(ok(await notes.getNote(99)), isNull);
  });

  test('lists pinned first, then the most recently edited', () async {
    await note('Old', daysAgo: 5);
    await note('Pinned old', pinned: true, daysAgo: 9);
    await note('New', daysAgo: 1);
    await note('Pinned new', pinned: true, daysAgo: 2);

    expect(titles(ok(await notes.getNotes())), ['Pinned new', 'Pinned old', 'New', 'Old']);
    expect(titles(ok(await notes.getPinnedNotes())), ['Pinned new', 'Pinned old']);
  });

  test('editing a note moves it up', () async {
    final old = await note('Old', daysAgo: 5);
    await note('New', daysAgo: 1);

    ok(await notes.updateNote(Note(id: old, title: 'Old, edited')));
    expect(titles(ok(await notes.getNotes())), ['Old, edited', 'New']);
  });

  test('pinning does not count as an edit', () async {
    final id = await note('Old', daysAgo: 5);
    ok(await notes.setPinned(id, true));
    final saved = ok(await notes.getNote(id))!;
    expect(saved.isPinned, isTrue);
    expect(saved.updatedAt, DateTime(2026, 9, 26));
  });

  test('changing a deleted note is NotFoundFailure', () async {
    expect(await notes.updateNote(const Note(id: 99, title: 'x')),
        const Error<void>(NotFoundFailure('Note not found')));
    expect(await notes.setPinned(99, true), const Error<void>(NotFoundFailure('Note not found')));
  });

  test('restoring a deleted note brings back its id and dates', () async {
    final id = await note('Suppliers', pinned: true, daysAgo: 3);
    final before = ok(await notes.getNote(id))!;

    ok(await notes.deleteNote(id));
    expect(ok(await notes.getNotes()), isEmpty);

    ok(await notes.restoreNote(before));
    expect(ok(await notes.getNote(id)), before);
  });
}
