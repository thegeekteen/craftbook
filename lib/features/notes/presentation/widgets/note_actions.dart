import 'package:flutter/material.dart';

import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/note.dart';
import '../../../../core/utils/l10n_extension.dart';

enum NoteAction { togglePin, delete }

/// The long-press menu on a note. Only picks; the Notes page carries the
/// action out through its bloc, Today through the use cases.
abstract final class NoteActions {
  static Future<NoteAction?> pick(BuildContext context, Note note) {
    final l10n = context.l10n;
    return showActionSheet<NoteAction>(
      context,
      title: note.titleOr(l10n.notesUntitled),
      actions: [
        SheetAction(
          value: NoteAction.togglePin,
          icon:
              note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
          label: note.isPinned ? l10n.notesUnpin : l10n.notesPinToToday,
        ),
        SheetAction(
          value: NoteAction.delete,
          icon: Icons.delete_outline_rounded,
          label: l10n.commonDelete,
          destructive: true,
        ),
      ],
    );
  }

  static Future<bool> confirmDelete(BuildContext context, Note note) {
    final l10n = context.l10n;
    return ConfirmDialog.show(
      context,
      title: l10n.notesDeleteTitle,
      message: l10n.notesDeleteMessage(note.titleOr(l10n.notesUntitled)),
      confirmText: l10n.commonDelete,
      isDestructive: true,
    );
  }
}
