import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/utils/l10n_extension.dart';

enum LeaveChoice { saveDraft, discard, keepEditing }

/// Asked when backing out of an order that isn't placed yet: keep it as a
/// draft, throw it away, or stay. Saving comes first because it's what
/// you almost always want.
class LeaveOrderDialog extends StatelessWidget {
  /// Reopened draft: Discard leaves the draft as it was rather than losing
  /// the order.
  final bool isDraft;

  const LeaveOrderDialog({super.key, this.isDraft = false});

  static Future<LeaveChoice?> show(BuildContext context,
          {bool isDraft = false}) =>
      showDialog<LeaveChoice>(
        context: context,
        builder: (_) => LeaveOrderDialog(isDraft: isDraft),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(isDraft ? l10n.ordersLeaveDraftTitle : l10n.ordersLeaveTitle),
      content: Text(
          isDraft ? l10n.ordersLeaveDraftMessage : l10n.ordersLeaveMessage),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(LeaveChoice.saveDraft),
              style: FilledButton.styleFrom(
                backgroundColor: c.go,
                foregroundColor: c.onAccent,
                minimumSize: const Size(0, 44),
              ),
              child: Text(l10n.ordersSaveDraft),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(LeaveChoice.discard),
              style: TextButton.styleFrom(foregroundColor: c.alert),
              child: Text(l10n.ordersDiscard),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(LeaveChoice.keepEditing),
              style: TextButton.styleFrom(foregroundColor: c.muted),
              child: Text(l10n.ordersKeepEditing),
            ),
          ],
        ),
      ],
    );
  }
}
