import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../domain/usecases/calculate_order_profit.dart';

/// Review step content for the new order wizard
class ReviewSummary extends StatelessWidget {
  final List<_MaterialRow> materials;
  final OrderProfitBreakdown? breakdown;

  const ReviewSummary({
    super.key,
    required this.materials,
    this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Material breakdown section
        Text(
          'MATERIALS',
          style: AppTextStyles.monoSection,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.paperHigh,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.hair),
          ),
          child: Column(
            children: [
              if (materials.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No materials to show',
                    style:
                        AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                  ),
                ),
              ...materials.asMap().entries.map((entry) {
                final i = entry.key;
                final mat = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: i < materials.length - 1
                        ? Border(bottom: BorderSide(color: AppColors.hair))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mat.name,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.ink),
                            ),
                            Text(
                              '${mat.quantity} pcs',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      CurrencyText(
                        amount: mat.quantity * mat.unitCost,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.ink),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Profit summary card
        if (breakdown != null) ...[
          Text(
            'PROFIT SUMMARY',
            style: AppTextStyles.monoSection,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.coinSoft.withOpacity(0.3),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.coin.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _ProfitRow(
                  label: 'Sales',
                  amount: breakdown!.totalSales,
                  color: AppColors.success,
                ),
                _ProfitRow(
                  label: 'Materials',
                  amount: -breakdown!.totalMaterialCost,
                  color: AppColors.alert,
                ),
                _ProfitRow(
                  label: 'Channel fees',
                  amount: -breakdown!.channelFees,
                  color: AppColors.warning,
                ),
                _ProfitRow(
                  label: 'Shipping',
                  amount: -breakdown!.shippingCost,
                  color: AppColors.muted,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: AppColors.hair),
                ),
                _ProfitRow(
                  label: 'Profit',
                  amount: breakdown!.profit,
                  color: breakdown!.profit >= 0
                      ? AppColors.success
                      : AppColors.alert,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MaterialRow {
  final String name;
  final int quantity;
  final double unitCost;

  const _MaterialRow({
    required this.name,
    required this.quantity,
    required this.unitCost,
  });
}

class _ProfitRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isTotal;

  const _ProfitRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(color: AppColors.ink)
                : AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
          CurrencyText(
            amount: amount.abs(),
            style: (isTotal ? AppTextStyles.displaySmall : AppTextStyles.bodyMedium)
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
