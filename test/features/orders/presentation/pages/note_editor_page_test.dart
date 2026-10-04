import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/core/utils/note_codec.dart';
import 'package:craftbook/features/orders/presentation/pages/note_editor_page.dart';
import 'package:craftbook/core/widgets/note/note_toolbar.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/note_harness.dart';

void main() {
  late Future<({String? note})?> popped;

  /// Mounts a button that opens the editor, so its pop value can be awaited.
  Future<void> open(WidgetTester tester, {String? note}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: noteTestDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => popped = NoteEditorPage.open(context, note: note),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settleNote(tester);
  }

  /// A formatting change, made the way a person makes it. Quill takes its own
  /// text input path, so injecting a whole string at once trips an assertion
  /// inside the package; toolbar actions go through the same code as the app.
  Future<void> makeFirstLineATodo(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Checklist'));
    await settleNote(tester, frames: 3);
  }

  group('NoteEditorPage', () {
    testWidgets('titles itself "Add note" when there is none', (tester) async {
      await open(tester);
      expect(find.text('Add note'), findsOneWidget);
    });

    testWidgets('titles itself "Edit note" over an existing note', (tester) async {
      await open(tester, note: 'Gift wrap');
      expect(find.text('Edit note'), findsOneWidget);
    });

    testWidgets('offers the formatting toolbar', (tester) async {
      await open(tester);
      expect(find.byType(NoteToolbar), findsOneWidget);
      for (final tool in ['Bold', 'Italic', 'Heading', 'Checklist', 'Bullet list']) {
        expect(find.byTooltip(tool), findsOneWidget, reason: tool);
      }
    });

    testWidgets('keeps the toolbar to one row under the editor', (tester) async {
      await open(tester);
      final toolbar = tester.getRect(find.byType(NoteToolbar));
      expect(toolbar.height, lessThanOrEqualTo(56), reason: 'the editor needs the screen');
      // Pinned to the bottom, where it rides on top of the keyboard.
      expect(toolbar.bottom, tester.view.physicalSize.height / tester.view.devicePixelRatio);
    });

    testWidgets('lights a toolbar button while its format is on', (tester) async {
      await open(tester, note: 'Gift wrap');
      IconButton checklist() => tester.widget<IconButton>(
            find.ancestor(of: find.byTooltip('Checklist'), matching: find.byType(IconButton)),
          );
      expect(checklist().isSelected, isFalse);

      await makeFirstLineATodo(tester);
      expect(checklist().isSelected, isTrue);
    });

    testWidgets('shows the note it was given', (tester) async {
      await open(tester, note: 'Gift wrap please');
      // Quill paints bare RichText, which the finder skips by default.
      expect(find.textContaining('Gift wrap please', findRichText: true), findsWidgets);
    });

    testWidgets('keeps formatting when a rich note is saved unchanged', (tester) async {
      final rich = NoteCodec.encode(
        Delta()
          ..insert('Wrap in ')
          ..insert('brown paper', {'bold': true})
          ..insert('\n'),
      )!;
      await open(tester, note: rich);
      await tester.tap(find.text('Save'));
      await settleNote(tester);

      final saved = await popped;
      expect(NoteCodec.decode(saved!.note).toList(), NoteCodec.decode(rich).toList());
    });

    testWidgets('saves a formatting change made in the toolbar', (tester) async {
      await open(tester, note: 'Gift wrap');
      await makeFirstLineATodo(tester);
      await tester.tap(find.text('Save'));
      await settleNote(tester);

      final saved = await popped;
      expect(saved, isNotNull);
      // The words survive, and the to-do lives on the line's own operation.
      expect(NoteCodec.plainText(saved!.note), 'Gift wrap');
      final todos = NoteCodec.decode(saved.note)
          .toList()
          .where((op) => op.attributes?['list'] == 'unchecked');
      expect(todos, isNotEmpty);
    });

    testWidgets('backing out of a change asks, and discards on confirm', (tester) async {
      await open(tester, note: 'Gift wrap');
      await makeFirstLineATodo(tester);
      await tester.tap(find.byTooltip('Close'));
      await settleNote(tester);

      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      // The dialog has to finish closing before the page can start its own
      // pop transition, so this needs longer than a single settle.
      await settleNote(tester, frames: 16);

      expect(await popped, isNull);
      expect(find.byType(NoteEditorPage), findsNothing);
    });

    testWidgets('keeping editing stays on the page', (tester) async {
      await open(tester, note: 'Gift wrap');
      await makeFirstLineATodo(tester);
      await tester.tap(find.byTooltip('Close'));
      await settleNote(tester);
      await tester.tap(find.text('Keep editing'));
      await settleNote(tester);

      expect(find.byType(NoteEditorPage), findsOneWidget);
      await tester.tap(find.text('Save'));
      await settleNote(tester);
      expect(NoteCodec.plainText((await popped)!.note), 'Gift wrap');
    });

    testWidgets('backing out of an untouched note needs no confirmation', (tester) async {
      await open(tester, note: 'Gift wrap');
      await tester.tap(find.byTooltip('Close'));
      await settleNote(tester);

      expect(find.text('Discard changes?'), findsNothing);
      expect(await popped, isNull);
    });
  });
}
