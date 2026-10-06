import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/money_breakdown.dart';

/// Profit one unit makes before channel fees, with the cost/profit bar.
class ProductProfitCard extends StatelessWidget {
  final double sellPrice;
  final double cost;
  final bool isStandalone;

  /// The product's unit, uppercased for the caption.
  final String unit;

  const ProductProfitCard({
    super.key,
    required this.sellPrice,
    required this.cost,
    required this.isStandalone,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final parts =
        MoneyParts(sales: sellPrice, materials: cost, fees: 0, shipping: 0);
    final positive = parts.profit >= 0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                    'PROFIT PER ${unit.isEmpty ? 'ITEM' : unit.toUpperCase()}',
                    style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
              ),
              Text(
                CurrencyFormatter.formatShort(parts.profit),
                style: AppTextStyles.displayMedium
                    .copyWith(fontSize: 26, color: positive ? c.go : c.alert),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MoneyBreakdownBar(parts: parts),
          const SizedBox(height: 8),
          Text(
            '${CurrencyFormatter.format(cost)} ${isStandalone ? 'cost' : 'materials'} · '
            '${(parts.margin * 100).round()}% margin · before channel fees',
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}
