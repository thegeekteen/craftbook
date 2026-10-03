import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Mono label over a value. Use in rows of two to four.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  /// Smaller body-weight value for secondary facts (unit cost, supplier).
  final bool compact;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.monoTag.copyWith(color: c.muted),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: compact
              ? AppTextStyles.bodyMedium.copyWith(
                  color: valueColor ?? c.ink,
                  fontWeight: FontWeight.w600,
                )
              : AppTextStyles.amount.copyWith(
                  color: valueColor ?? c.ink,
                  fontSize: 19,
                ),
        ),
      ],
    );
  }
}

/// Lays out [StatTile]s in equal columns.
class StatRow extends StatelessWidget {
  final List<Widget> children;

  const StatRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}
