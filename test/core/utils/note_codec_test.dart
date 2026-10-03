import 'dart:convert';

import 'package:craftbook/core/utils/note_codec.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';

/// A note with some formatting on it, as the editor would produce it.
Delta get _richNote => Delta()
  ..insert('Wrap in ')
  ..insert('brown paper', {'bold': true})
  ..insert('\n');

void main() {
  group('encode', () {
    test('stores nothing for a blank note', () {
      expect(NoteCodec.encode(Delta()..insert('\n')), isNull);
      expect(NoteCodec.encode(Delta()..insert('  \n \n')), isNull);
      expect(NoteCodec.encode(Delta()), isNull);
    });

    test('writes Delta JSON rather than the bare text', () {
      final encoded = NoteCodec.encode(Delta()..insert('Gift wrap\n'));
      expect(jsonDecode(encoded!), [
        {'insert': 'Gift wrap\n'},
      ]);
    });

    test('keeps formatting through a round trip', () {
      final decoded = NoteCodec.decode(NoteCodec.encode(_richNote));
      expect(decoded.toList(), _richNote.toList());
    });
  });

  group('decode', () {
    test('reads a note written before rich text existed', () {
      final delta = NoteCodec.decode('Gift wrap please, birthday on the 5th');
      expect(NoteCodec.textOf(delta), 'Gift wrap please, birthday on the 5th\n');
    });

    test('turns null and blank into an empty document', () {
      for (final raw in [null, '', '   ', '\n']) {
        expect(NoteCodec.textOf(NoteCodec.decode(raw)), '\n', reason: 'raw: ${jsonEncode(raw)}');
        expect(NoteCodec.isBlank(raw), isTrue);
      }
    });

    test('upgrades a legacy note to Delta JSON when it is saved again', () {
      expect(
        jsonDecode(NoteCodec.encode(NoteCodec.decode('Gift wrap'))!),
        [
          {'insert': 'Gift wrap\n'},
        ],
      );
    });

    test('survives malformed JSON', () {
      expect(NoteCodec.textOf(NoteCodec.decode('[{"insert":]')), '[{"insert":]\n');
    });

    test('survives JSON that is not a Delta', () {
      expect(NoteCodec.textOf(NoteCodec.decode('[1,2,3]')), '[1,2,3]\n');
      expect(NoteCodec.textOf(NoteCodec.decode('{"insert":"x"}')), '{"insert":"x"}\n');
    });

    test('survives a Delta whose operations are not inserts', () {
      expect(NoteCodec.textOf(NoteCodec.decode('[{"retain":4}]')), '');
    });
  });

  group('plainText', () {
    test('flattens a multi-line note into one preview line', () {
      final encoded = NoteCodec.encode(
        Delta()
          ..insert('Gift wrap\n')
          ..insert('Birthday on the 5th\n'),
      );
      expect(NoteCodec.plainText(encoded), 'Gift wrap Birthday on the 5th');
    });

    test('drops formatting, embeds and blank lines', () {
      final encoded = NoteCodec.encode(
        Delta()
          ..insert('Before ')
          ..insert({'image': 'file:///photos/box.png'})
          ..insert('after\n')
          ..insert('\n'),
      );
      expect(NoteCodec.plainText(encoded), 'Before after');
    });

    test('reads a legacy note exactly as stored', () {
      expect(NoteCodec.plainText('Gift wrap please'), 'Gift wrap please');
      expect(NoteCodec.plainText(null), '');
    });
  });

  group('isBlank', () {
    test('is only true when nothing would be shown', () {
      expect(NoteCodec.isBlank(NoteCodec.encode(_richNote)), isFalse);
      expect(NoteCodec.isBlank('legacy text'), isFalse);
      expect(NoteCodec.isBlank(NoteCodec.encode(Delta()..insert('\n'))), isTrue);
      expect(NoteCodec.isBlank('[{"insert":"\\n"}]'), isTrue);
    });
  });
}
