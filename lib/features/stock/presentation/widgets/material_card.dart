import 'package:flutter/material.dart' hide Material;

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../domain/entities/material.dart';

/// Material in the stock list: name, on-hand count, pips and a one-line
/// summary (free · promised · reorder level · unit cost).
class MaterialCard extends StatelessWidget {
  final Material material;
  final VoidCallback? onTap;

  const MaterialCard({super.key, required this.material, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final m = material;
    final low = m.isLowStock;
    final short = m.quantityFree < 0 ? -m.quantityFree : 0;
    final summary = [
      '${m.quantityFree < 0 ? 0 : m.quantityFree} free',
      if (m.quantityPromised > 0) '${m.quantityPromised} promised',
      'reorder at ${m.alertLevel}',
      '${CurrencyFormatter.format(m.unitCost)}/pc',
    ].join(' · ');

    return AppCard(
      onTap: onTap,
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
                    if (low) const AppTag.low(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${m.quantityOnHand}',
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
            isLow: low,
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: summary),
              if (short > 0)
                TextSpan(
                  text: ' · $short short',
                  style: TextStyle(color: c.alert, fontWeight: FontWeight.w600),
                ),
            ]),
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}
