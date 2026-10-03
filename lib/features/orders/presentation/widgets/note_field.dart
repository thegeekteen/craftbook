import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/note_codec.dart';
import '../pages/note_editor_page.dart';
import 'note_view.dart';

/// Tappable note box for the order form, showing the note fully formatted.
///
/// It fills whatever height its parent gives it, so the form can hand it the
/// space left under the other fields; tapping anywhere opens the editor.
class NoteField extends StatelessWidget {
  /// The stored note: Quill Delta JSON, or legacy plain text.
  final String? note;

  /// Called with the note to store, or null when it was cleared.
  final ValueChanged<String?> onChanged;

  const NoteField({super.key, required this.note, required this.onChanged});

  Future<void> _edit(BuildContext context) async {
    final saved = await NoteEditorPage.open(context, note: note);
    // Null means backed out; the note is left as it was.
    if (saved != null) onChanged(saved.note);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filled = !NoteCodec.isBlank(note);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.controlAll,
        side: BorderSide(color: c.hair),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _edit(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    filled ? Icons.sticky_note_2_rounded : Icons.sticky_note_2_outlined,
                    size: 16,
                    color: filled ? c.warn : c.muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Note (optional)',
                      style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                    ),
                  ),
                  Icon(
                    filled ? Icons.edit_outlined : Icons.add_rounded,
                    size: 18,
                    color: c.muted,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: filled
                    // The box is one big button, so the note itself must not
                    // swallow taps (or tick to-dos) on the way.
                    ? IgnorePointer(child: NoteView(raw: note!))
                    : Text(
                        'Gift wrap, colour requests, packing steps…',
                        style: AppTextStyles.bodyMedium.copyWith(color: c.muted),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
