import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/note_bodies.dart';

void main() {
  group('displayTitle', () {
    test('is the title when there is one', () {
      expect(
          Note(title: '  Suppliers ', body: noteBody(['Ribbon shop']))
              .displayTitle,
          'Suppliers');
    });

    test('falls back to the first non-empty line of the body', () {
      expect(
          Note(body: noteBody(['', '  Ribbon shop  ', 'Call Mon']))
              .displayTitle,
          'Ribbon shop');
    });

    test('is "Untitled" when there is nothing at all', () {
      expect(const Note().displayTitle, 'Untitled');
      expect(
          Note(title: '  ', body: noteBody(['   '])).displayTitle, 'Untitled');
    });

    test('reads a legacy plain-text body', () {
      expect(const Note(body: 'Plain words\nmore').displayTitle, 'Plain words');
    });
  });

  test('preview is the body on one line', () {
    expect(Note(body: noteBody(['Ribbon', 'Boxes'])).preview, 'Ribbon Boxes');
    expect(const Note().preview, '');
  });

  group('checklist', () {
    test('counts ticked and total to-do lines', () {
      final note = Note(
          body: noteBody(['Packing', '[x] Ribbon', '[ ] Boxes', '[x] Tape']));
      expect(note.checklist, (done: 2, total: 3));
    });

    test('is empty for a note without to-dos', () {
      expect(
          Note(body: noteBody(['Just text'])).checklist, (done: 0, total: 0));
      expect(const Note().checklist, (done: 0, total: 0));
    });

    test('counts each line when Quill merges newlines into one op', () {
      const body =
          '[{"insert":"A"},{"insert":"\\n","attributes":{"list":"unchecked"}},'
          '{"insert":"B"},{"insert":"\\n\\n","attributes":{"list":"checked"}}]';
      expect(const Note(body: body).checklist, (done: 2, total: 3));
    });
  });

  group('matches', () {
    final note =
        Note(title: 'Suppliers', body: noteBody(['Ribbon from Divisoria']));

    test('an empty query matches everything', () {
      expect(note.matches(''), isTrue);
      expect(note.matches('   '), isTrue);
    });

    test('matches the title or the body, ignoring case', () {
      expect(note.matches('supp'), isTrue);
      expect(note.matches('DIVISORIA'), isTrue);
      expect(note.matches('boxes'), isFalse);
    });

    test('does not match the JSON around the words', () {
      expect(note.matches('insert'), isFalse);
    });
  });
}
