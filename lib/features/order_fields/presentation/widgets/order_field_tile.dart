import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../domain/entities/order_field.dart';

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
  static String describe(OrderField field) {
    final parts = [
      if (field.type == OrderFieldType.text && field.isMultiline) 'Multi-line',
      if (field.type == OrderFieldType.choice)
        '${field.options.length} ${field.options.length == 1 ? 'choice' : 'choices'}',
      field.isUsed
          ? 'used on ${field.usageCount} ${field.usageCount == 1 ? 'order' : 'orders'}'
          : 'not used yet',
    ];
    final text = parts.join(' · ');
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
                    AppTag(field.type.label, type: AppTagType.outline),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  describe(field),
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
