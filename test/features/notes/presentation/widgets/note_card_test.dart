import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:craftbook/features/notes/presentation/widgets/note_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/note_bodies.dart';
import '../../../../support/note_harness.dart';

void main() {
  Future<void> pump(WidgetTester tester, NoteCard card) => tester.pumpWidget(
      wrapWithTheme(Padding(padding: const EdgeInsets.all(16), child: card)));

  testWidgets('shows the title, a preview and checklist progress',
      (tester) async {
    await pump(
      tester,
      NoteCard(
        note: Note(
          id: 1,
          title: 'Packing',
          body:
              noteBody(['Before posting', '[x] Ribbon', '[ ] Thank-you card']),
          updatedAt: DateTime.now(),
        ),
      ),
    );
    expect(find.text('Packing'), findsOneWidget);
    expect(find.text('Before posting Ribbon Thank-you card'), findsOneWidget);
    expect(find.text('1/2 DONE'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('an untitled note does not repeat its first line',
      (tester) async {
    await pump(
        tester, NoteCard(note: Note(id: 1, body: noteBody(['Ribbon shop']))));
    expect(find.text('Ribbon shop'), findsOneWidget);
  });

  testWidgets('without a pin action, a pinned note just shows the pin',
      (tester) async {
    await pump(
        tester, const NoteCard(note: Note(id: 1, title: 'A', isPinned: true)));
    expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('the pin button toggles and the card opens', (tester) async {
    var pins = 0;
    var taps = 0;
    await pump(
      tester,
      NoteCard(
        note: const Note(id: 1, title: 'A'),
        onTap: () => taps++,
        onTogglePin: () => pins++,
      ),
    );
    await tester.tap(find.byTooltip('Pin'));
    await tester.tap(find.text('A'));
    expect((pins, taps), (1, 1));
  });

  testWidgets('compact keeps the preview to one line', (tester) async {
    final note = Note(id: 1, title: 'A', body: noteBody(['long ' * 40]));
    await pump(tester, NoteCard(note: note, compact: true));
    final preview = tester.widget<Text>(find.textContaining('long long'));
    expect(preview.maxLines, 1);
  });
}
