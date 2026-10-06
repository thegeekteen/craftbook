import 'dart:math';

import 'package:dart_quill_delta/dart_quill_delta.dart';

import '../utils/note_codec.dart';
import 'fake_shop.dart';
import 'fake_vocabulary.dart';

/// The shop's notebook.
///
/// A pinned checklist (Today shows it), a formatted page, and a page with
/// nothing but plain lines — the three things the note list renders
/// differently.
List<NotePlan> buildNotes(Random random) {
  final titles = takeSome(random, noteTitles, 5, noteTitles.length);
  final plans = <NotePlan>[];

  void add(String title, Delta? body, {bool pinned = false}) => plans.add(
        NotePlan(
          ref: plans.length + 1,
          title: title,
          body: body == null ? null : NoteCodec.encode(body),
          pinned: pinned,
        ),
      );

  add(
    titles[0],
    Delta()
      ..line('Before every parcel', {'header': 2})
      ..line('Bubble wrap round the stems', {'list': 'checked'})
      ..line('Thank-you card with care tips', {'list': 'checked'})
      ..line('Photo of the parcel for the buyer', {'list': 'unchecked'})
      ..line('Waybill taped flat', {'list': 'unchecked'})
      ..insert('Fragile', {'background': 'warn', 'bold': true})
      ..insert(' sticker on resin orders.\n'),
    pinned: true,
  );

  add(
    titles[1],
    Delta()
      ..line(
          'Yarn: Divisoria, stall 14 (ask for Aling Nena)', {'list': 'bullet'})
      ..line('Resin & molds: online, ships Tuesdays', {'list': 'bullet'})
      ..line('Kraft boxes cheaper by 100s.', {'blockquote': true})
      ..line('Courier picks up at 4pm, gate code 1234.', {'italic': true}),
  );

  add(
    titles[2],
    Delta()
      ..line('Order more sage yarn before November', {'header': 3})
      ..insert('Two hundred grams, ', {'bold': true})
      ..insert('and the gold wire is nearly out.\n')
      ..line('Reprice the hoop art — felt went up again', {'list': 'checked'})
      ..line(
          'Photograph the new bookmarks for the page', {'list': 'unchecked'}),
  );

  // No formats at all, so the list shows a preview the way a note typed before
  // the notebook could format looks.
  add(
      titles[3],
      Delta()
        ..insert('Twelve bouquets, four delivered, the rest picked up.\n'));

  // Title only: a page that is nothing but a heading so far.
  add(titles[4], null);

  return plans;
}

extension on Delta {
  /// One line with a block format, which Quill keeps on the newline only.
  void line(String text, Map<String, Object?> format) => this
    ..insert(text)
    ..insert('\n', format);
}
