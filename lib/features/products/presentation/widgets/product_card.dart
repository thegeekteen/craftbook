import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../domain/entities/product.dart';

/// Product card widget for list displays
class ProductCard extends StatelessWidget {
  final Product product;
  final int? buildableQuantity;
  final double? materialCost;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.buildableQuantity,
    this.materialCost,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final margin = materialCost != null && materialCost! > 0
        ? ((product.sellPrice - materialCost!) / product.sellPrice * 100)
            .clamp(0, 100)
        : null;

    final marginColor = margin == null
        ? AppColors.muted
        : margin > 50
            ? AppColors.success
            : margin > 20
                ? AppColors.warning
                : AppColors.alert;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: name + active indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color:
                            product.isActive ? AppColors.ink : AppColors.muted,
                      ),
                    ),
                  ),
                  if (!product.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.hair,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'INACTIVE',
                        style: AppTextStyles.monoLabel
                            .copyWith(color: AppColors.muted, fontSize: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Prices
              Row(
                children: [
                  if (materialCost != null) ...[
                    Text(
                      'Cost: ',
                      style: AppTextStyles.bodySmall,
                    ),
                    CurrencyText(
                      amount: materialCost!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.alert),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    'Sell: ',
                    style: AppTextStyles.bodySmall,
                  ),
                  CurrencyText(
                    amount: product.sellPrice,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.success),
                  ),
                ],
              ),

              // Margin bar
              if (margin != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Margin ${margin.toStringAsFixed(0)}%',
                      style: AppTextStyles.monoLabel.copyWith(
                        color: marginColor,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: margin / 100,
                    minHeight: 4,
                    backgroundColor: AppColors.hair,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(marginColor),
                  ),
                ),
              ],

              // Buildable / stock quantity
              if (buildableQuantity != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      product.isStandalone
                          ? Icons.inventory_outlined
                          : Icons.inventory_2_outlined,
                      size: 12,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.isStandalone
                          ? 'In stock: $buildableQuantity'
                          : 'Can build: $buildableQuantity',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: buildableQuantity! == 0
                            ? AppColors.alert
                            : AppColors.muted,
                      ),
                    ),
                    if (product.isStandalone && product.isLowStock) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.alert.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LOW',
                          style: AppTextStyles.monoLabel.copyWith(
                            color: AppColors.alert,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
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
