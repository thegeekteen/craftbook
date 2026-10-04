import 'package:craftbook/app.dart';
import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart' hide Note;
import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:craftbook/features/notes/domain/repositories/note_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/note_bodies.dart';

T _ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// The notebook end to end: list, editor, More and Today.
void main() {
  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await getIt.reset();
      await configureDependencies(
          database: AppDatabase.forTesting(NativeDatabase.memory()));
    });
  }

  Future<void> open(WidgetTester tester, String location) async {
    await tester.pumpWidget(CraftbookApp(initialLocation: location));
    await _settle(tester);
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => getIt<AppDatabase>().close());
  }

  Future<int> note(WidgetTester tester, Note n) async => (await tester
      .runAsync(() async => _ok(await getIt<NoteRepository>().createNote(n))))!;

  Future<List<Note>> stored(WidgetTester tester) async => (await tester
      .runAsync(() async => _ok(await getIt<NoteRepository>().getNotes())))!;

  testWidgets('starts empty and writes a first note', (tester) async {
    await start(tester);
    await open(tester, RouteNames.notes);
    expect(find.text('No notes yet'), findsOneWidget);

    await tester.tap(find.text('Add note'));
    await _settle(tester);
    expect(find.text('New note'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Title'), 'Ribbon suppliers');
    await tester.tap(find.byTooltip('Pin to Today'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Ribbon suppliers'), findsOneWidget);
    expect(find.text('PINNED · 1'), findsOneWidget);
    final saved = (await stored(tester)).single;
    expect((saved.title, saved.isPinned), ('Ribbon suppliers', true));
    await teardown(tester);
  });

  testWidgets('closing a blank new note saves nothing', (tester) async {
    await start(tester);
    await open(tester, RouteNames.notes);
    await tester.tap(find.text('Add note'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);
    expect(find.text('No notes yet'), findsOneWidget);
    expect(await stored(tester), isEmpty);
    await teardown(tester);
  });

  testWidgets('asks before throwing away an edit', (tester) async {
    await start(tester);
    final id = await note(tester, const Note(title: 'Suppliers'));
    await open(tester, RouteNames.notes);
    await tester.tap(find.text('Suppliers'));
    await _settle(tester);

    await tester.enterText(
        find.widgetWithText(TextField, 'Suppliers'), 'Changed');
    await tester.tap(find.byTooltip('Close'));
    await _settle(tester);
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await _settle(tester);

    expect(find.text('Suppliers'), findsOneWidget);
    expect((await stored(tester)).single,
        isA<Note>().having((n) => n.id, 'id', id));
    expect((await stored(tester)).single.title, 'Suppliers');
    await teardown(tester);
  });

  testWidgets('searches titles and bodies', (tester) async {
    await start(tester);
    await note(tester,
        Note(title: 'Suppliers', body: noteBody(['Ribbon from Divisoria'])));
    await note(tester, const Note(title: 'Ideas'));
    await open(tester, RouteNames.notes);

    await tester.enterText(
        find.widgetWithText(TextField, 'Search notes'), 'divisoria');
    await _settle(tester);
    expect(find.text('Suppliers'), findsOneWidget);
    expect(find.text('Ideas'), findsNothing);

    await tester.enterText(
        find.widgetWithText(TextField, 'Search notes'), 'boxes');
    await _settle(tester);
    expect(find.text('No matches'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('pins from the list', (tester) async {
    await start(tester);
    await note(tester, const Note(title: 'Suppliers'));
    await open(tester, RouteNames.notes);

    await tester.tap(find.byTooltip('Pin'));
    await _settle(tester);
    expect(find.text('PINNED · 1'), findsOneWidget);
    expect((await stored(tester)).single.isPinned, isTrue);
    await teardown(tester);
  });

  testWidgets('deletes from the editor and undoes it', (tester) async {
    await start(tester);
    await note(tester, const Note(title: 'Suppliers'));
    await open(tester, RouteNames.notes);
    await tester.tap(find.text('Suppliers'));
    await _settle(tester);

    await tester.tap(find.byTooltip('More'));
    await _settle(tester);
    await tester.tap(find.text('Delete'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await _settle(tester);

    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Suppliers deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await _settle(tester);
    expect(find.text('Suppliers'), findsOneWidget);
    expect(await stored(tester), hasLength(1));
    await teardown(tester);
  });

  testWidgets('deletes from the long-press menu', (tester) async {
    await start(tester);
    await note(tester, const Note(title: 'Suppliers'));
    await open(tester, RouteNames.notes);

    await tester.longPress(find.text('Suppliers'));
    await _settle(tester);
    await tester.tap(find.text('Delete'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await _settle(tester);

    expect(find.text('No notes yet'), findsOneWidget);
    expect(await stored(tester), isEmpty);
    await teardown(tester);
  });

  testWidgets('a deleted note says so instead of opening', (tester) async {
    await start(tester);
    await open(tester, RouteNames.notePath(42));
    expect(find.text('This note was deleted'), findsOneWidget);
    await teardown(tester);
  });

  group('More', () {
    testWidgets('counts notes and opens the notebook', (tester) async {
      await start(tester);
      await note(tester, const Note(title: 'A', isPinned: true));
      await note(tester, const Note(title: 'B'));
      await open(tester, RouteNames.settings);

      await tester.scrollUntilVisible(find.text('2 notes · 1 pinned'), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Notes'));
      await _settle(tester);
      expect(find.text('PINNED · 1'), findsOneWidget);
      await teardown(tester);
    });
  });

  group('Today', () {
    testWidgets('shows pinned notes only', (tester) async {
      await start(tester);
      await note(tester, const Note(title: 'Supplier numbers', isPinned: true));
      await note(tester, const Note(title: 'Loose idea'));
      await open(tester, RouteNames.today);

      expect(find.text('PINNED NOTES · 1'), findsOneWidget);
      expect(find.text('Supplier numbers'), findsOneWidget);
      expect(find.text('Loose idea'), findsNothing);
      await teardown(tester);
    });

    testWidgets('hides the section when nothing is pinned', (tester) async {
      await start(tester);
      await note(tester, const Note(title: 'Loose idea'));
      await open(tester, RouteNames.today);
      expect(find.textContaining('PINNED NOTES'), findsNothing);
      await teardown(tester);
    });

    testWidgets('unpinning in the editor drops the note from Today',
        (tester) async {
      await start(tester);
      await note(tester, const Note(title: 'Supplier numbers', isPinned: true));
      await open(tester, RouteNames.today);

      await tester.tap(find.text('Supplier numbers'));
      await _settle(tester);
      await tester.tap(find.byTooltip('Unpin'));
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await _settle(tester);

      expect(find.textContaining('PINNED NOTES'), findsNothing);
      await teardown(tester);
    });
  });
}

/// Real database work runs outside the fake clock, and the editor's cursor
/// never settles, so pump a fixed run of frames instead of pumpAndSettle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
