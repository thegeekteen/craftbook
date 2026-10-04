import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:craftbook/features/notes/domain/repositories/note_repository.dart';
import 'package:craftbook/features/notes/domain/usecases/delete_note.dart';
import 'package:craftbook/features/notes/domain/usecases/get_note.dart';
import 'package:craftbook/features/notes/domain/usecases/get_notes.dart';
import 'package:craftbook/features/notes/domain/usecases/get_pinned_notes.dart';
import 'package:craftbook/features/notes/domain/usecases/restore_note.dart';
import 'package:craftbook/features/notes/domain/usecases/save_note.dart';
import 'package:craftbook/features/notes/domain/usecases/set_note_pinned.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/note_bodies.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  late MockNoteRepository repo;

  setUpAll(() => registerFallbackValue(const Note()));
  setUp(() => repo = MockNoteRepository());

  const note = Note(id: 1, title: 'Suppliers');

  test('GetNotes returns what the repository has', () async {
    when(() => repo.getNotes()).thenAnswer((_) async => const Success([note]));
    expect(await GetNotes(repo)(), const Success([note]));
  });

  test('GetPinnedNotes returns the pinned notes', () async {
    when(() => repo.getPinnedNotes()).thenAnswer((_) async => const Success([note]));
    expect(await GetPinnedNotes(repo)(), const Success([note]));
  });

  group('GetNote', () {
    test('returns the note', () async {
      when(() => repo.getNote(1)).thenAnswer((_) async => const Success(note));
      expect(await GetNote(repo)(1), const Success(note));
    });

    test('a missing note is NotFoundFailure', () async {
      when(() => repo.getNote(1)).thenAnswer((_) async => const Success(null));
      expect(await GetNote(repo)(1), const Error<Note>(NotFoundFailure('This note was deleted')));
    });

    test('passes a database failure through', () async {
      when(() => repo.getNote(1)).thenAnswer((_) async => const Error(DatabaseFailure('db')));
      expect(await GetNote(repo)(1), const Error<Note>(DatabaseFailure('db')));
    });
  });

  group('SaveNote', () {
    test('creates a new note with a trimmed title', () async {
      when(() => repo.createNote(any())).thenAnswer((_) async => const Success(7));
      final body = noteBody(['Ribbon']);

      expect(await SaveNote(repo)(Note(title: '  Suppliers  ', body: body)), const Success(7));
      verify(() => repo.createNote(Note(title: 'Suppliers', body: body))).called(1);
    });

    test('updates an existing note and returns its id', () async {
      when(() => repo.updateNote(any())).thenAnswer((_) async => const Success(null));
      expect(await SaveNote(repo)(note), const Success(1));
      verify(() => repo.updateNote(note)).called(1);
    });

    test('stores an emptied body as null', () async {
      when(() => repo.updateNote(any())).thenAnswer((_) async => const Success(null));
      await SaveNote(repo)(Note(id: 1, title: 'Suppliers', body: noteBody(['  '])));
      verify(() => repo.updateNote(const Note(id: 1, title: 'Suppliers'))).called(1);
    });

    test('keeps a note with a body but no title', () async {
      when(() => repo.createNote(any())).thenAnswer((_) async => const Success(2));
      expect(await SaveNote(repo)(Note(body: noteBody(['Ribbon']))), const Success(2));
    });

    test('refuses a note with neither title nor body', () async {
      final result = await SaveNote(repo)(Note(title: '  ', body: noteBody([''])));
      expect(result, const Error<int>(ValidationFailure('Write something first')));
      verifyNever(() => repo.createNote(any()));
    });

    test('passes an update failure through', () async {
      when(() => repo.updateNote(any()))
          .thenAnswer((_) async => const Error(NotFoundFailure('Note not found')));
      expect(await SaveNote(repo)(note), const Error<int>(NotFoundFailure('Note not found')));
    });
  });

  test('SetNotePinned pins through the repository', () async {
    when(() => repo.setPinned(1, true)).thenAnswer((_) async => const Success(null));
    expect(await SetNotePinned(repo)(1, true), const Success<void>(null));
  });

  test('DeleteNote deletes through the repository', () async {
    when(() => repo.deleteNote(1)).thenAnswer((_) async => const Success(null));
    expect(await DeleteNote(repo)(1), const Success<void>(null));
  });

  test('RestoreNote puts the note back as it was', () async {
    when(() => repo.restoreNote(note)).thenAnswer((_) async => const Success(null));
    expect(await RestoreNote(repo)(note), const Success<void>(null));
  });
}
