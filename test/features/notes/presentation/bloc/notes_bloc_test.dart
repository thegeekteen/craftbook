import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:craftbook/features/notes/domain/usecases/delete_note.dart';
import 'package:craftbook/features/notes/domain/usecases/get_notes.dart';
import 'package:craftbook/features/notes/domain/usecases/restore_note.dart';
import 'package:craftbook/features/notes/domain/usecases/set_note_pinned.dart';
import 'package:craftbook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:craftbook/features/notes/presentation/bloc/notes_event.dart';
import 'package:craftbook/features/notes/presentation/bloc/notes_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetNotes extends Mock implements GetNotes {}

class MockSetNotePinned extends Mock implements SetNotePinned {}

class MockDeleteNote extends Mock implements DeleteNote {}

class MockRestoreNote extends Mock implements RestoreNote {}

void main() {
  late MockGetNotes getNotes;
  late MockSetNotePinned setNotePinned;
  late MockDeleteNote deleteNote;
  late MockRestoreNote restoreNote;

  const suppliers = Note(id: 1, title: 'Suppliers', isPinned: true);
  const ideas =
      Note(id: 2, title: 'Ideas', body: '[{"insert":"Pressed flowers\\n"}]');
  const notes = [suppliers, ideas];

  setUpAll(() => registerFallbackValue(const Note()));

  setUp(() {
    getNotes = MockGetNotes();
    setNotePinned = MockSetNotePinned();
    deleteNote = MockDeleteNote();
    restoreNote = MockRestoreNote();
    when(() => getNotes()).thenAnswer((_) async => const Success(notes));
  });

  NotesBloc build() => NotesBloc(
        getNotes: getNotes,
        setNotePinned: setNotePinned,
        deleteNote: deleteNote,
        restoreNote: restoreNote,
      );

  test('initial state is NotesInitial', () {
    expect(build().state, isA<NotesInitial>());
  });

  group('LoadNotes', () {
    blocTest<NotesBloc, NotesState>(
      'emits loading then the notes',
      build: build,
      act: (bloc) => bloc.add(const LoadNotes()),
      expect: () => [isA<NotesLoading>(), const NotesLoaded(all: notes)],
    );

    blocTest<NotesBloc, NotesState>(
      'emits an error when loading fails',
      setUp: () => when(() => getNotes())
          .thenAnswer((_) async => const Error(DatabaseFailure('db'))),
      build: build,
      act: (bloc) => bloc.add(const LoadNotes()),
      expect: () => [isA<NotesLoading>(), const NotesError('db')],
    );

    blocTest<NotesBloc, NotesState>(
      'a reload keeps the search',
      build: build,
      seed: () => const NotesLoaded(all: [], query: 'flow'),
      act: (bloc) => bloc.add(const LoadNotes()),
      expect: () => [const NotesLoaded(all: notes, query: 'flow')],
    );
  });

  group('SearchNotes', () {
    blocTest<NotesBloc, NotesState>(
      'filters the visible notes',
      build: build,
      seed: () => const NotesLoaded(all: notes),
      act: (bloc) => bloc.add(const SearchNotes('flowers')),
      expect: () => [const NotesLoaded(all: notes, query: 'flowers')],
      verify: (bloc) {
        final state = bloc.state as NotesLoaded;
        expect(state.visible, [ideas]);
        expect(state.pinned, isEmpty);
        expect(state.others, [ideas]);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'is ignored before the notes load',
      build: build,
      act: (bloc) => bloc.add(const SearchNotes('x')),
      expect: () => <NotesState>[],
    );
  });

  group('ToggleNotePinEvent', () {
    blocTest<NotesBloc, NotesState>(
      'unpins a pinned note and reloads',
      setUp: () => when(() => setNotePinned(1, false))
          .thenAnswer((_) async => const Success(null)),
      build: build,
      seed: () => const NotesLoaded(all: notes),
      act: (bloc) => bloc.add(const ToggleNotePinEvent(1)),
      expect: () => [
        NotesLoaded(
            all: notes,
            outcome: NoteOutcome.unpinned,
            subject: notes.first,
            serial: 1)
      ],
      verify: (_) => verify(() => setNotePinned(1, false)).called(1),
    );

    blocTest<NotesBloc, NotesState>(
      'pins an unpinned note',
      setUp: () => when(() => setNotePinned(2, true))
          .thenAnswer((_) async => const Success(null)),
      build: build,
      seed: () => const NotesLoaded(all: notes),
      act: (bloc) => bloc.add(const ToggleNotePinEvent(2)),
      expect: () => [
        NotesLoaded(
            all: notes,
            outcome: NoteOutcome.pinned,
            subject: notes[1],
            serial: 1)
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'reports a failure and keeps the list',
      setUp: () => when(() => setNotePinned(1, false))
          .thenAnswer((_) async => const Error(DatabaseFailure('locked'))),
      build: build,
      seed: () => const NotesLoaded(all: notes),
      act: (bloc) => bloc.add(const ToggleNotePinEvent(1)),
      expect: () => [
        const NotesLoaded(
            all: notes, message: 'locked', isError: true, serial: 1)
      ],
    );
  });

  group('DeleteNoteEvent', () {
    blocTest<NotesBloc, NotesState>(
      'deletes, reloads and hands back the note for Undo',
      setUp: () {
        when(() => deleteNote(2)).thenAnswer((_) async => const Success(null));
        when(() => getNotes())
            .thenAnswer((_) async => const Success([suppliers]));
      },
      build: build,
      seed: () => const NotesLoaded(all: notes),
      act: (bloc) => bloc.add(const DeleteNoteEvent(2)),
      expect: () => [
        const NotesLoaded(
            all: [suppliers],
            outcome: NoteOutcome.deleted,
            subject: ideas,
            serial: 1,
            deleted: ideas),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'does nothing for a note that is not in the list',
      build: build,
      seed: () => const NotesLoaded(all: notes),
      act: (bloc) => bloc.add(const DeleteNoteEvent(99)),
      expect: () => <NotesState>[],
      verify: (_) => verifyNever(() => deleteNote(any())),
    );
  });

  blocTest<NotesBloc, NotesState>(
    'RestoreNoteEvent puts the note back and reloads',
    setUp: () => when(() => restoreNote(ideas))
        .thenAnswer((_) async => const Success(null)),
    build: build,
    seed: () => const NotesLoaded(all: [suppliers]),
    act: (bloc) => bloc.add(const RestoreNoteEvent(ideas)),
    expect: () => [
      const NotesLoaded(
          all: notes, outcome: NoteOutcome.restored, subject: ideas, serial: 1)
    ],
  );
}
