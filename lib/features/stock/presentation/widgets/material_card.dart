import 'package:flutter/material.dart' hide Material;

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../domain/entities/material.dart';

/// Material in the stock list: name, on-hand count, pips and a one-line
/// summary (free · promised · reorder level · unit cost).
class MaterialCard extends StatelessWidget {
  final Material material;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MaterialCard(
      {super.key, required this.material, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final m = material;
    // An archived material isn't restocked, so it never reads as low.
    final low = m.isLowStock && !m.isArchived;
    final short = m.quantityFree < 0 ? -m.quantityFree : 0;
    final summary = [
      '${QuantityFormatter.format(m.quantityFree < 0 ? 0 : m.quantityFree)} free',
      if (m.quantityPromised > 0)
        '${QuantityFormatter.format(m.quantityPromised)} promised',
      'reorder at ${QuantityFormatter.format(m.alertLevel)}',
      // The unit rides on the cost, so the whole line reads in one unit.
      '${CurrencyFormatter.format(m.unitCost)}'
          '${m.unit.isEmpty ? '' : '/${m.unit}'}',
    ].join(' · ');

    final card = AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      borderColor: low ? c.alert.withValues(alpha: 0.55) : null,
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
                    Text(
                      m.name,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: low ? c.alert : c.ink),
                    ),
                    if (m.isArchived) const AppTag('Archived'),
                    if (low) const AppTag.low(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                QuantityFormatter.format(m.quantityOnHand),
                style: AppTextStyles.amount
                    .copyWith(color: low ? c.alert : c.ink, fontSize: 19),
              ),
            ],
          ),
          const SizedBox(height: 10),
          PipStrip(
            total: m.quantityOnHand,
            free: m.quantityFree,
            promised: m.quantityPromised,
            alertLevel: m.alertLevel,
            unit: m.unit,
            isLow: low,
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: summary),
              if (short > 0)
                TextSpan(
                  text: ' · ${QuantityFormatter.withUnit(short, m.unit)} short',
                  style: TextStyle(color: c.alert, fontWeight: FontWeight.w600),
                ),
            ]),
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
        ],
      ),
    );
    return m.isArchived ? Opacity(opacity: 0.6, child: card) : card;
  }
}
