import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/text_styles.dart';
import '../utils/currency_formatter.dart';

/// Where a sale went: materials, fees, shipping and what's left as profit.
///
/// Profit is always derived from the parts (never a stored value), in line
/// with business rule 5.
class MoneyParts {
  final double sales;
  final double materials;
  final double fees;
  final double shipping;

  const MoneyParts({
    required this.sales,
    required this.materials,
    required this.fees,
    required this.shipping,
  });

  double get costs => materials + fees + shipping;
  double get profit => sales - costs;

  /// Profit as a share of sales, 0–1. Zero when there are no sales.
  double get margin => sales <= 0 ? 0 : profit / sales;
}

/// Horizontal stacked bar: materials (red), fees (amber), shipping (grey),
/// profit (green). When costs exceed sales the bar shows costs only.
class MoneyBreakdownBar extends StatelessWidget {
  final MoneyParts parts;
  final double height;

  const MoneyBreakdownBar({super.key, required this.parts, this.height = 12});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profit = parts.profit > 0 ? parts.profit : 0.0;
    final segments = <(double, Color)>[
      (parts.materials, c.alert),
      (parts.fees, c.warn),
      (parts.shipping, c.muted),
      (profit, c.go),
    ].where((s) => s.$1 > 0).toList();
    final total = segments.fold<double>(0, (sum, s) => sum + s.$1);

    return Semantics(
      label: 'Profit ${CurrencyFormatter.format(parts.profit)} of '
          '${CurrencyFormatter.format(parts.sales)} sales',
      child: ClipRRect(
        borderRadius: AppRadii.pillAll,
        child: SizedBox(
          height: height,
          child: total <= 0
              ? ColoredBox(color: c.hair)
              : Row(
                  // Childless ColoredBoxes need tight height to paint.
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < segments.length; i++) ...[
                      if (i > 0) SizedBox(width: 2, child: ColoredBox(color: c.surface)),
                      Expanded(
                        // Flex needs ints; scale to keep small slices visible.
                        flex: (segments[i].$1 / total * 1000).round().clamp(1, 1000),
                        child: ColoredBox(color: segments[i].$2),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// Bar plus the Sales / Materials / Fees / Shipping rows.
///
/// [feesLabel] lets callers name the channel ("Shopee fees").
/// [onMaterialsTap] makes the materials row tappable (e.g. to expand lines).
class MoneyBreakdown extends StatelessWidget {
  final MoneyParts parts;
  final String feesLabel;
  final String materialsLabel;
  final VoidCallback? onMaterialsTap;
  final bool showBar;

  const MoneyBreakdown({
    super.key,
    required this.parts,
    this.feesLabel = 'Channel fees',
    this.materialsLabel = 'Materials',
    this.onMaterialsTap,
    this.showBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBar) ...[
          MoneyBreakdownBar(parts: parts),
          const SizedBox(height: 10),
        ],
        MoneyRow(label: 'Sales', amount: parts.sales),
        MoneyRow(
          label: materialsLabel,
          amount: -parts.materials,
          dot: c.alert,
          color: c.alert,
          onTap: onMaterialsTap,
        ),
        MoneyRow(label: feesLabel, amount: -parts.fees, dot: c.warn, color: c.warn),
        MoneyRow(
          label: 'Shipping',
          amount: -parts.shipping,
          dot: c.muted,
          color: c.muted,
        ),
      ],
    );
  }
}

/// Label on the left, signed amount on the right.
class MoneyRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? dot;
  final Color? color;
  final VoidCallback? onTap;
  final TextStyle? amountStyle;

  const MoneyRow({
    super.key,
    required this.label,
    required this.amount,
    this.dot,
    this.color,
    this.onTap,
    this.amountStyle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = amount < 0
        ? '−${CurrencyFormatter.format(-amount)}'
        : CurrencyFormatter.format(amount);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (dot != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: c.ink),
            ),
          ),
          Text(
            text,
            style: amountStyle ??
                AppTextStyles.bodyMedium.copyWith(
                  color: color ?? c.ink,
                  fontWeight: FontWeight.w600,
                  fontFeatures: AppTextStyles.tabular.fontFeatures,
                ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 18, color: c.muted),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: row,
    );
  }
}
