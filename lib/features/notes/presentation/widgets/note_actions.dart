import 'package:flutter/material.dart';

import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/note.dart';

enum NoteAction { togglePin, delete }

/// The long-press menu on a note. Only picks; the Notes page carries the
/// action out through its bloc, Today through the use cases.
abstract final class NoteActions {
  static Future<NoteAction?> pick(BuildContext context, Note note) {
    return showActionSheet<NoteAction>(
      context,
      title: note.displayTitle,
      actions: [
        SheetAction(
          value: NoteAction.togglePin,
          icon:
              note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
          label: note.isPinned ? 'Unpin' : 'Pin to Today',
        ),
        const SheetAction(
          value: NoteAction.delete,
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          destructive: true,
        ),
      ],
    );
  }

  static Future<bool> confirmDelete(BuildContext context, Note note) {
    return ConfirmDialog.show(
      context,
      title: 'Delete note?',
      message: '${note.displayTitle} is removed from your notebook.',
      confirmText: 'Delete',
      isDestructive: true,
    );
  }
}
