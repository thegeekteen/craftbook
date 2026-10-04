import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../domain/entities/note.dart';

/// One note in the notebook or on Today: title, a peek at the body, checklist
/// progress and when it was last edited.
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Shows a pin button that toggles; without it a pinned note only shows
  /// the pin.
  final VoidCallback? onTogglePin;

  /// One line of preview instead of two, for Today.
  final bool compact;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.onTogglePin,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final preview = note.preview;
    // An untitled note shows its first line as the title; don't repeat it.
    final showPreview = preview.isNotEmpty && preview != note.displayTitle;
    final checklist = note.checklist;
    final updated = note.updatedAt;
    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(color: c.ink, fontWeight: FontWeight.w600),
                ),
                if (showPreview) ...[
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(color: c.muted),
                  ),
                ],
                if (checklist.total > 0 || updated != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (checklist.total > 0) ...[
                        AppTag(
                          '${checklist.done}/${checklist.total} done',
                          type: checklist.done == checklist.total ? AppTagType.ok : AppTagType.neutral,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      if (updated != null)
                        Text(
                          app_date.DateUtils.friendly(updated),
                          style: AppTextStyles.monoTag.copyWith(color: c.muted),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onTogglePin != null)
            IconButton(
              tooltip: note.isPinned ? 'Unpin' : 'Pin',
              onPressed: onTogglePin,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                size: 20,
                color: note.isPinned ? c.go : c.muted,
              ),
            )
          else if (note.isPinned)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
              child: Icon(Icons.push_pin_rounded, size: 16, color: c.go, semanticLabel: 'Pinned'),
            ),
        ],
      ),
    );
  }
}
