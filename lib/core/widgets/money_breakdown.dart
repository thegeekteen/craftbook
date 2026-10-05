import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/text_styles.dart';
import '../utils/currency_formatter.dart';

/// Where a sale went: discounts, tax, materials, fees, shipping and what's
/// left as profit.
///
/// Profit is always derived from the parts (never a stored value), in line
/// with business rule 5, and matches `OrderMoney.profit`.
class MoneyParts {
  /// Item prices before discounts.
  final double sales;
  final double discount;

  /// Tax inside the prices: it comes out of sales.
  final double includedTax;

  /// Tax the customer paid on top: passed on, so not part of profit.
  final double addedTax;
  final double materials;
  final double fees;
  final double shipping;

  const MoneyParts({
    required this.sales,
    this.discount = 0,
    this.includedTax = 0,
    this.addedTax = 0,
    required this.materials,
    required this.fees,
    required this.shipping,
  });

  /// Sales after discounts.
  double get netSales => sales - discount;
  double get costs => materials + fees + shipping;
  double get profit => netSales - includedTax - costs;

  /// Profit as a share of sales after discounts, 0–1. Zero when there are
  /// no sales.
  double get margin => netSales <= 0 ? 0 : profit / netSales;
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
      (parts.includedTax, c.coin),
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
                      if (i > 0)
                        SizedBox(width: 2, child: ColoredBox(color: c.surface)),
                      Expanded(
                        // Flex needs ints; scale to keep small slices visible.
                        flex: (segments[i].$1 / total * 1000)
                            .round()
                            .clamp(1, 1000),
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

/// Bar plus the Sales / Discount / Tax / Materials / Fees / Shipping rows.
/// Discount and tax rows only show when there is any.
///
/// [feesLabel] lets callers name the channel ("Shopee fees").
/// [onMaterialsTap] makes the materials row tappable (e.g. to expand lines).
class MoneyBreakdown extends StatelessWidget {
  final MoneyParts parts;
  final String feesLabel;
  final String materialsLabel;
  final VoidCallback? onMaterialsTap;
  final bool showBar;

  /// What the tax is called ("VAT").
  final String taxLabel;

  const MoneyBreakdown({
    super.key,
    required this.parts,
    this.feesLabel = 'Channel fees',
    this.materialsLabel = 'Materials',
    this.onMaterialsTap,
    this.showBar = true,
    this.taxLabel = 'Tax',
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
        if (parts.discount > 0)
          MoneyRow(label: 'Discounts', amount: -parts.discount),
        if (parts.includedTax > 0)
          MoneyRow(
            label: '$taxLabel in prices',
            amount: -parts.includedTax,
            dot: c.coin,
            color: c.coin,
          ),
        MoneyRow(
          label: materialsLabel,
          amount: -parts.materials,
          dot: c.alert,
          color: c.alert,
          onTap: onMaterialsTap,
        ),
        MoneyRow(
            label: feesLabel, amount: -parts.fees, dot: c.warn, color: c.warn),
        MoneyRow(
          label: 'Shipping',
          amount: -parts.shipping,
          dot: c.muted,
          color: c.muted,
        ),
        if (parts.addedTax > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${CurrencyFormatter.format(parts.addedTax)} $taxLabel added '
              'for the customer to pay. It isn\'t yours, so it\'s not in '
              'profit.',
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
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

/// The bottom line under a [MoneyBreakdown]: a hairline, then profit and
/// margin in green or red.
class ProfitRow extends StatelessWidget {
  final MoneyParts parts;

  const ProfitRow({super.key, required this.parts});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = parts.profit >= 0 ? c.go : c.alert;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Divider(height: 1, color: c.hair),
        ),
        MoneyRow(
          label: 'Profit · ${(parts.margin * 100).round()}% margin',
          amount: parts.profit,
          amountStyle: AppTextStyles.amount.copyWith(color: color),
        ),
      ],
    );
  }
}
