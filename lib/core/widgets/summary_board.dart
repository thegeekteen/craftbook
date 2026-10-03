import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/text_styles.dart';

/// A secondary figure under the board's headline number.
class BoardStat {
  final String label;
  final String value;

  /// Overrides the label colour, e.g. red for "Overdue".
  final Color? labelColor;

  const BoardStat({required this.label, required this.value, this.labelColor});
}

/// Dark summary panel: label, headline number, optional extra content
/// (e.g. a chart) and up to four secondary stats.
class SummaryBoard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final List<BoardStat> stats;
  final Widget? child;
  final VoidCallback? onTap;

  const SummaryBoard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.stats = const [],
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.board,
      borderRadius: AppRadii.cardAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.monoLabel.copyWith(color: c.boardMuted),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: valueColor ?? c.boardInk,
                  ),
                ),
              ),
              if (child != null) ...[const SizedBox(height: 14), child!],
              if (stats.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(height: 1, color: c.boardRaised),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in stats)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                s.value,
                                style: AppTextStyles.displaySmall.copyWith(
                                  color: c.boardInk,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures:
                                      AppTextStyles.tabular.fontFeatures,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.monoTag.copyWith(
                                color: s.labelColor ?? c.boardMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
