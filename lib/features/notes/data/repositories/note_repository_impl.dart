import 'package:drift/drift.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/note_dao.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteDao dao;

  NoteRepositoryImpl(this.dao);

  @override
  Future<Result<List<Note>>> getNotes() => _guard(() async {
        return [for (final row in await dao.getAll()) _toEntity(row)];
      });

  @override
  Future<Result<List<Note>>> getPinnedNotes() => _guard(() async {
        return [for (final row in await dao.getPinned()) _toEntity(row)];
      });

  @override
  Future<Result<Note?>> getNote(int id) => _guard(() async {
        final row = await dao.getById(id);
        return row == null ? null : _toEntity(row);
      });

  @override
  Future<Result<int>> createNote(Note note) => _guard(() {
        return dao.insertNote(db.NotesCompanion.insert(
          title: Value(note.title),
          body: Value(note.body),
          isPinned: Value(note.isPinned),
        ));
      });

  @override
  Future<Result<void>> updateNote(Note note) async {
    final result = await _guard(() {
      return dao.updateNote(
        note.id!,
        db.NotesCompanion(
          title: Value(note.title),
          body: Value(note.body),
          isPinned: Value(note.isPinned),
        ),
      );
    });
    return _found(result);
  }

  @override
  Future<Result<void>> setPinned(int id, bool pinned) async {
    return _found(await _guard(() => dao.setPinned(id, pinned)));
  }

  @override
  Future<Result<void>> deleteNote(int id) => _guard(() => dao.deleteNote(id));

  @override
  Future<Result<void>> restoreNote(Note note) => _guard(() {
        return dao.insertNote(db.NotesCompanion.insert(
          id: Value.absentIfNull(note.id),
          title: Value(note.title),
          body: Value(note.body),
          isPinned: Value(note.isPinned),
          createdAt: Value.absentIfNull(note.createdAt),
          updatedAt: Value.absentIfNull(note.updatedAt),
        ));
      });

  static Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  /// An update that touched no row means the note is gone.
  static Result<void> _found(Result<int> updated) => switch (updated) {
        Success(value: 0) => const Error(NotFoundFailure('Note not found')),
        Success() => const Success(null),
        Error(:final failure) => Error(failure),
      };

  static Note _toEntity(db.Note row) => Note(
        id: row.id,
        title: row.title,
        body: row.body,
        isPinned: row.isPinned,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
