import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../../../core/widgets/product_photo.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../domain/entities/product.dart';
import '../../domain/product_stock_status.dart';

/// Details card at the top of a product's page: what's available now,
/// then price, cost and margin.
///
/// Resell products show their own stock as pips. Handmade products show
/// how many the materials on hand can build.
class ProductSummaryCard extends StatelessWidget {
  final Product product;

  /// Cost of one piece: the BOM total for handmade, unit cost for resell.
  final double cost;

  /// How much the materials on hand can build, unrounded. Ignored for resell.
  /// The headline floors it, since you can't pack part of a product.
  final double buildable;

  /// Pending orders want more than stock or materials can cover.
  final bool isShort;

  const ProductSummaryCard({
    super.key,
    required this.product,
    required this.cost,
    this.buildable = 0,
    this.isShort = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = product;
    final qty = p.isStandalone ? p.quantityOnHand : buildable.floorToDouble();
    final low = isProductLow(p, buildable);
    final alertQty = low || isShort || sameQty(qty, 0);
    final margin =
        (MoneyParts(sales: p.sellPrice, materials: cost, fees: 0, shipping: 0)
                    .margin *
                100)
            .round();
    final marginColor = margin >= 50 ? c.go : (margin >= 20 ? c.warn : c.alert);
    final photo = p.photo;

    return AppCard(
      borderColor: low || isShort ? c.alert.withValues(alpha: 0.55) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photo != null) ...[
            Semantics(
              image: true,
              label: 'Photo of ${p.name}',
              button: true,
              child: GestureDetector(
                onTap: () =>
                    showPhotoViewer(context, bytes: photo, title: p.name),
                child: ClipRRect(
                  borderRadius: AppRadii.controlAll,
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.memory(photo,
                        fit: BoxFit.cover, gaplessPlayback: true),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                QuantityFormatter.format(qty),
                style: AppTextStyles.displayLarge
                    .copyWith(color: alertQty ? c.alert : c.ink, fontSize: 44),
              ),
              const SizedBox(width: 8),
              Text(
                p.isStandalone
                    ? (p.unit.isEmpty
                        ? 'ON HAND'
                        : '${p.unit.toUpperCase()} ON HAND')
                    : 'CAN BUILD',
                style: AppTextStyles.monoLabel.copyWith(color: c.muted),
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                children: [
                  if (p.isStandalone) const AppTag('Resell'),
                  if (p.isArchived) const AppTag('Archived'),
                  // Resell already shows its shortfall as a stat below.
                  if (isShort && !p.isStandalone)
                    const AppTag.low(text: 'Short'),
                  if (low) const AppTag.low(),
                ],
              ),
            ],
          ),
          if (p.isStandalone) ...[
            const SizedBox(height: 12),
            PipStrip(
              total: p.quantityOnHand,
              free: p.quantityFree,
              promised: p.quantityPromised,
              alertLevel: p.alertLevel,
              unit: p.unit,
              isLow: low,
              size: PipSize.large,
            ),
            const SizedBox(height: 8),
            const PipLegend(),
            const SizedBox(height: 14),
            StatRow(children: [
              p.quantityFree < 0
                  ? StatTile(
                      label: 'Short',
                      value: QuantityFormatter.format(-p.quantityFree),
                      valueColor: c.alert)
                  : StatTile(
                      label: 'Free',
                      value: QuantityFormatter.format(p.quantityFree),
                      valueColor: c.go),
              StatTile(
                label: 'Promised',
                value: QuantityFormatter.format(p.quantityPromised),
                valueColor: p.quantityPromised > 0 ? c.alert : null,
              ),
              StatTile(
                  label: 'Reorder at',
                  value: QuantityFormatter.format(p.alertLevel)),
            ]),
          ],
          if (!p.isStandalone && p.alertLevel > 0) ...[
            const SizedBox(height: 14),
            StatRow(children: [
              StatTile(
                  label: 'Warn at',
                  value: QuantityFormatter.format(p.alertLevel)),
            ]),
          ],
          const SizedBox(height: 12),
          Divider(color: c.hair),
          const SizedBox(height: 12),
          StatRow(children: [
            StatTile(
                label: 'Sell price',
                value: CurrencyFormatter.format(p.sellPrice),
                compact: true),
            StatTile(
                label: 'Cost',
                value: CurrencyFormatter.format(cost),
                compact: true),
            StatTile(
              label: 'Margin',
              value: '${margin < 0 ? '−${-margin}' : margin}%',
              valueColor: marginColor,
              compact: true,
            ),
          ]),
          if (p.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(p.description!.trim(),
                style: AppTextStyles.bodySmall
                    .copyWith(color: c.muted, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
