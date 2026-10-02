import 'package:flutter/material.dart' hide Material;

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../domain/entities/material.dart';

/// Material card widget for list displays
class MaterialCard extends StatelessWidget {
  final Material material;
  final VoidCallback? onTap;

  const MaterialCard({
    super.key,
    required this.material,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = material.isLowStock;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
          side: BorderSide(
            color: isLow ? AppColors.alert.withOpacity(0.4) : AppColors.hair,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: name + alert pill
              Row(
                children: [
                  Expanded(
                    child: Text(
                      material.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isLow ? AppColors.alert : AppColors.ink,
                      ),
                    ),
                  ),
                  if (isLow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.alertSoft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LOW',
                        style: AppTextStyles.monoLabel
                            .copyWith(color: AppColors.alert, fontSize: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Pack info + unit cost
              Row(
                children: [
                  Text(
                    'Pack of ${material.packSize}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  CurrencyText(
                    amount: material.unitCost,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.muted),
                  ),
                  const Spacer(),
                  Text(
                    'Alert: ${material.alertLevel}',
                    style: AppTextStyles.monoLabel
                        .copyWith(color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Pip strip
              PipStrip(
                total: material.quantityOnHand.clamp(0, 50),
                free: material.quantityFree.clamp(0, 50),
                promised: material.quantityPromised.clamp(0, 50),
                isLow: isLow,
              ),
              const SizedBox(height: 8),

              // Quantity display
              Row(
                children: [
                  _QuantityLabel(
                    label: 'On hand',
                    value: material.quantityOnHand,
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: 12),
                  _QuantityLabel(
                    label: 'Free',
                    value: material.quantityFree,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  _QuantityLabel(
                    label: 'Promised',
                    value: material.quantityPromised,
                    color: AppColors.alert,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityLabel extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _QuantityLabel({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.monoLabel.copyWith(
            color: AppColors.muted,
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          '$value',
          style: AppTextStyles.bodyMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
