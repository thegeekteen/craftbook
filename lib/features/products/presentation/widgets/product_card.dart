import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../../../core/widgets/product_photo.dart';
import '../../domain/entities/product.dart';
import '../../domain/product_stock_status.dart';

/// Product in the catalogue: price, cost/profit bar, margin and how many
/// you can make (or have) right now.
class ProductCard extends StatelessWidget {
  final Product product;
  final double? unitCost;

  /// Unrounded: what the materials can build, or a resell product's free
  /// stock. The card floors it for display.
  final double? available;

  /// Pending orders want more than stock or materials can cover.
  final bool isShort;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProductCard({
    super.key,
    required this.product,
    this.unitCost,
    this.available,
    this.isShort = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final p = product;
    final cost = unitCost ?? 0;
    final parts =
        MoneyParts(sales: p.sellPrice, materials: cost, fees: 0, shipping: 0);
    final margin = (parts.margin * 100).round();
    final marginColor = margin >= 50 ? c.go : (margin >= 20 ? c.warn : c.alert);
    final qty = available ?? 0;
    // You can't pack part of a handmade product, so its headline floors.
    final shown = p.isStandalone ? qty : qty.floorToDouble();
    final lowStock = isProductLow(p, available);

    return Opacity(
      opacity: p.isArchived ? 0.6 : 1,
      child: AppCard(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductPhoto(bytes: p.photo, name: p.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(p.name,
                          style:
                              AppTextStyles.bodyLarge.copyWith(color: c.ink)),
                      if (p.isStandalone) AppTag(l10n.productsTagResell),
                      if (p.isArchived) AppTag(l10n.productsTagArchived),
                      if (isShort)
                        AppTag.low(text: l10n.productsTagShortForOrders),
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
                      TextSpan(
                          text:
                              '${l10n.productsCardCost(CurrencyFormatter.formatShort(cost))} · '),
                      TextSpan(
                        text: l10n.productsCardMargin(
                            margin < 0 ? '−${-margin}' : '$margin'),
                        style: TextStyle(
                            color: marginColor, fontWeight: FontWeight.w600),
                      ),
                    ]),
                    style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                  ),
                ),
                if (available != null) ...[
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text:
                              '${p.isStandalone ? l10n.productsInStock : l10n.productsCanBuild} '),
                      TextSpan(
                        text: QuantityFormatter.format(shown),
                        style: TextStyle(
                          color:
                              sameQty(shown, 0) || lowStock ? c.alert : c.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (p.unit.isNotEmpty) TextSpan(text: ' ${p.unit}'),
                    ]),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: sameQty(shown, 0) ? c.alert : c.muted),
                  ),
                  if (lowStock) ...[
                    const SizedBox(width: 6),
                    const AppTag.low()
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
