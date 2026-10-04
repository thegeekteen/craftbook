import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:craftbook/features/notes/domain/usecases/delete_note.dart';
import 'package:craftbook/features/notes/domain/usecases/get_note.dart';
import 'package:craftbook/features/notes/domain/usecases/save_note.dart';
import 'package:craftbook/features/notes/presentation/bloc/note_edit_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetNote extends Mock implements GetNote {}

class MockSaveNote extends Mock implements SaveNote {}

class MockDeleteNote extends Mock implements DeleteNote {}

void main() {
  late MockGetNote getNote;
  late MockSaveNote saveNote;
  late MockDeleteNote deleteNote;

  const note = Note(id: 1, title: 'Suppliers');

  setUp(() {
    getNote = MockGetNote();
    saveNote = MockSaveNote();
    deleteNote = MockDeleteNote();
  });

  NoteEditCubit build() =>
      NoteEditCubit(getNote: getNote, saveNote: saveNote, deleteNote: deleteNote);

  test('starts loading', () {
    expect(build().state.isLoading, isTrue);
  });

  blocTest<NoteEditCubit, NoteEditState>(
    'a new note starts blank',
    build: build,
    act: (cubit) => cubit.load(null),
    expect: () => [const NoteEditState(note: Note())],
    verify: (_) => verifyNever(() => getNote(any())),
  );

  blocTest<NoteEditCubit, NoteEditState>(
    'loads an existing note',
    setUp: () => when(() => getNote(1)).thenAnswer((_) async => const Success(note)),
    build: build,
    act: (cubit) => cubit.load(1),
    expect: () => [const NoteEditState(note: note)],
  );

  blocTest<NoteEditCubit, NoteEditState>(
    'says when the note is gone',
    setUp: () => when(() => getNote(1))
        .thenAnswer((_) async => const Error(NotFoundFailure('This note was deleted'))),
    build: build,
    act: (cubit) => cubit.load(1),
    expect: () => [const NoteEditState(error: 'This note was deleted')],
  );

  test('save and delete hand back the use case result', () async {
    when(() => saveNote(note)).thenAnswer((_) async => const Success(1));
    when(() => deleteNote(1)).thenAnswer((_) async => const Error(DatabaseFailure('db')));
    final cubit = build();
    expect(await cubit.save(note), const Success(1));
    expect(await cubit.delete(1), const Error<void>(DatabaseFailure('db')));
    await cubit.close();
  });
}
