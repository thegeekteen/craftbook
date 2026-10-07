import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../domain/entities/order_field.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../order_field_labels.dart';

/// One field in the settings list: name, type, and what it holds.
class OrderFieldTile extends StatelessWidget {
  final OrderField field;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Drag handle for reordering; null for archived fields.
  final Widget? leading;
  final Widget? trailing;

  const OrderFieldTile({
    super.key,
    required this.field,
    this.onTap,
    this.onLongPress,
    this.leading,
    this.trailing,
  });

  /// "Multi-line · used on 4 orders", "3 choices", "Not used yet".
  static String describe(AppLocalizations l10n, OrderField field) {
    final parts = [
      if (field.type == OrderFieldType.text && field.isMultiline)
        l10n.orderFieldsMultiline,
      if (field.type == OrderFieldType.choice)
        l10n.orderFieldsChoiceCount(field.options.length),
      field.isUsed
          ? l10n.orderFieldsUsedOn(field.usageCount)
          : l10n.orderFieldsNotUsed,
    ];
    final text = parts.join(' · ');
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.fromLTRB(6, 10, 10, 10),
      child: Row(
        children: [
          leading ?? const SizedBox(width: 8),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        field.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: field.isArchived ? c.muted : c.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppTag(field.type.localized(l10n),
                        type: AppTagType.outline),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  describe(l10n, field),
                  style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
