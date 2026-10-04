import 'package:craftbook/core/utils/note_codec.dart';
import 'package:craftbook/features/orders/presentation/pages/note_editor_page.dart';
import 'package:craftbook/features/orders/presentation/widgets/note_field.dart';
import 'package:craftbook/core/widgets/note/note_view.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/note_harness.dart';

/// Two lines, one of them partly bold, as the editor would store it.
final String _richNote = NoteCodec.encode(
  Delta()
    ..insert('Wrap in ')
    ..insert('brown paper', {'bold': true})
    ..insert('\n')
    ..insert('Birthday on the 5th\n'),
)!;

/// Quill paints bare RichText, which the finders skip unless asked.
Finder _text(String fragment) => find.textContaining(fragment, findRichText: true);

/// The themed to-do box NoteStyles draws in place of Quill's default.
Finder _checkbox() => find.byType(AnimatedContainer).first;

void main() {
  group('NoteField', () {
    testWidgets('invites a note when there is none', (tester) async {
      await tester.pumpWidget(wrapWithTheme(NoteField(note: null, onChanged: (_) {})));

      expect(find.text('Note (optional)'), findsOneWidget);
      expect(find.textContaining('Gift wrap, colour requests'), findsOneWidget);
      expect(find.byType(NoteView), findsNothing);
    });

    testWidgets('shows a rich note in full, formatted', (tester) async {
      await tester.pumpWidget(wrapWithTheme(NoteField(note: _richNote, onChanged: (_) {})));
      await settleNote(tester);

      expect(find.byType(NoteView), findsOneWidget);
      expect(_text('Wrap in brown paper'), findsWidgets);
      expect(_text('Birthday on the 5th'), findsWidgets);
    });

    testWidgets('shows a legacy plain-text note exactly as stored', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(NoteField(note: 'Gift wrap please', onChanged: (_) {})),
      );
      await settleNote(tester);

      expect(_text('Gift wrap please'), findsWidgets);
    });

    testWidgets('opens the editor and takes back what was saved', (tester) async {
      String? stored = 'Gift wrap please';
      await tester.pumpWidget(wrapWithTheme(StatefulBuilder(
        builder: (context, setState) => NoteField(
          note: stored,
          onChanged: (value) => setState(() => stored = value),
        ),
      )));

      await tester.tap(find.byType(NoteField));
      await settleNote(tester);
      expect(find.byType(NoteEditorPage), findsOneWidget);

      await tester.tap(find.text('Save'));
      await settleNote(tester, frames: 16);

      // Saved untouched, but re-encoded: a legacy note becomes Delta JSON.
      expect(stored, isNot('Gift wrap please'));
      expect(NoteCodec.plainText(stored), 'Gift wrap please');
      expect(find.byType(NoteEditorPage), findsNothing);
      expect(_text('Gift wrap please'), findsWidgets);
    });

    testWidgets('leaves the note alone when the editor is dismissed', (tester) async {
      String? stored = 'Gift wrap please';
      await tester.pumpWidget(wrapWithTheme(StatefulBuilder(
        builder: (context, setState) => NoteField(
          note: stored,
          onChanged: (value) => setState(() => stored = value),
        ),
      )));

      await tester.tap(find.byType(NoteField));
      await settleNote(tester);
      await tester.tap(find.byTooltip('Close'));
      await settleNote(tester, frames: 16);

      expect(stored, 'Gift wrap please');
    });
  });

  group('NoteView', () {
    testWidgets('renders a rich note', (tester) async {
      await tester.pumpWidget(wrapWithTheme(NoteView(raw: _richNote)));
      await settleNote(tester);

      expect(_text('Wrap in brown paper'), findsWidgets);
      expect(_text('Birthday on the 5th'), findsWidgets);
    });

    testWidgets('renders a note written before rich text existed', (tester) async {
      await tester.pumpWidget(wrapWithTheme(const NoteView(raw: 'Gift wrap please')));
      await settleNote(tester);

      expect(_text('Gift wrap please'), findsWidgets);
    });

    testWidgets('ticking a to-do hands back the updated note', (tester) async {
      final todo = NoteCodec.encode(Delta()..insert('Ring twice\n', {'list': 'unchecked'}))!;
      String? changed;
      await tester.pumpWidget(wrapWithTheme(NoteView(raw: todo, onChanged: (n) => changed = n)));
      await settleNote(tester);

      await tester.tap(_checkbox());
      await settleNote(tester);

      expect(NoteCodec.decode(changed).toList().last.attributes, {'list': 'checked'});
    });

    testWidgets('to-dos are display-only without onChanged', (tester) async {
      final todo = NoteCodec.encode(Delta()..insert('Ring twice\n', {'list': 'unchecked'}))!;
      await tester.pumpWidget(wrapWithTheme(NoteView(raw: todo)));
      await settleNote(tester);

      await tester.tap(_checkbox(), warnIfMissed: false);
      await settleNote(tester);

      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('puts the stored note back when a tick was not saved', (tester) async {
      final todo = NoteCodec.encode(Delta()..insert('Ring twice\n', {'list': 'unchecked'}))!;
      // The parent ignores the change, as it does when the save fails.
      Widget view() => wrapWithTheme(NoteView(raw: todo, onChanged: (_) {}));
      await tester.pumpWidget(view());
      await settleNote(tester);
      await tester.tap(_checkbox());
      await settleNote(tester);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.pumpWidget(view());
      await settleNote(tester);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('shows the new note when the order changes', (tester) async {
      await tester.pumpWidget(wrapWithTheme(const NoteView(raw: 'First note')));
      await settleNote(tester);
      await tester.pumpWidget(wrapWithTheme(const NoteView(raw: 'Second note')));
      await settleNote(tester);

      expect(_text('Second note'), findsWidgets);
      expect(_text('First note'), findsNothing);
    });
  });
}
