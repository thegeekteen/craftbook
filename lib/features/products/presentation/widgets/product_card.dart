import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../domain/entities/product.dart';

/// Product in the catalogue: price, cost/profit bar, margin and how many
/// you can make (or have) right now.
class ProductCard extends StatelessWidget {
  final Product product;
  final double? unitCost;
  final int? available;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.unitCost,
    this.available,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = product;
    final cost = unitCost ?? 0;
    final parts = MoneyParts(sales: p.sellPrice, materials: cost, fees: 0, shipping: 0);
    final margin = (parts.margin * 100).round();
    final marginColor = margin >= 50 ? c.go : (margin >= 20 ? c.warn : c.alert);
    final qty = available ?? 0;
    final lowStock = p.isStandalone ? p.isLowStock : qty > 0 && qty < 5;

    return Opacity(
      opacity: p.isActive ? 1 : 0.6,
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(p.name, style: AppTextStyles.bodyLarge.copyWith(color: c.ink)),
                      if (p.isStandalone) const AppTag('Resell'),
                      if (!p.isActive) const AppTag('Hidden'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  CurrencyFormatter.formatShort(p.sellPrice),
                  style: AppTextStyles.amount.copyWith(color: c.ink),
                ),
              ],
            ),
            const SizedBox(height: 10),
            MoneyBreakdownBar(parts: parts, height: 8),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: 'Cost ${CurrencyFormatter.formatShort(cost)} · '),
                      TextSpan(
                        text: '${margin < 0 ? '−${-margin}' : margin}% margin',
                        style: TextStyle(color: marginColor, fontWeight: FontWeight.w600),
                      ),
                    ]),
                    style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                  ),
                ),
                if (available != null) ...[
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: p.isStandalone ? 'In stock ' : 'Can build '),
                      TextSpan(
                        text: '$qty',
                        style: TextStyle(
                          color: qty == 0 || lowStock ? c.alert : c.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                    style: AppTextStyles.bodySmall.copyWith(color: qty == 0 ? c.alert : c.muted),
                  ),
                  if (lowStock) ...[const SizedBox(width: 6), const AppTag.low()],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
