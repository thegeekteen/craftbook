import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../domain/entities/earnings_summary.dart';

/// Earnings summary card widget — large profit display with breakdown
class EarningsSummaryCard extends StatelessWidget {
  final EarningsSummary summary;

  const EarningsSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.coinSoft.withOpacity(0.3),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.coin.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large profit number
          Text(
            'NET PROFIT',
            style: AppTextStyles.monoSection.copyWith(color: AppColors.coin),
          ),
          const SizedBox(height: 4),
          CurrencyText(
            amount: summary.totalProfit,
            style: AppTextStyles.displayLarge.copyWith(
              color: summary.totalProfit >= 0
                  ? AppColors.coin
                  : AppColors.alert,
            ),
          ),
          Text(
            '${summary.orderCount} orders',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.coin),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.hair),
          const SizedBox(height: 8),

          // Breakdown rows
          _BreakdownRow(
            label: 'Sales',
            amount: summary.totalSales,
            color: AppColors.success,
          ),
          const SizedBox(height: 6),
          _BreakdownRow(
            label: 'Material cost',
            amount: summary.totalMaterialCost,
            color: AppColors.alert,
          ),
          const SizedBox(height: 6),
          _BreakdownRow(
            label: 'Channel fees',
            amount: summary.totalChannelFees,
            color: AppColors.warning,
          ),
          const SizedBox(height: 6),
          _BreakdownRow(
            label: 'Shipping',
            amount: summary.totalShippingCost,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _BreakdownRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
        CurrencyText(
          amount: amount,
          style: AppTextStyles.bodyMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
