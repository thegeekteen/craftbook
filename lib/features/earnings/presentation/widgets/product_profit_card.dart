import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../domain/entities/product_earnings.dart';

/// Per-product profit card
class ProductProfitCard extends StatelessWidget {
  final ProductEarnings earnings;

  const ProductProfitCard({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earnings.productName,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  '${earnings.quantitySold} sold',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CurrencyText(
                amount: earnings.totalSales,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 2),
              CurrencyText(
                amount: earnings.totalProfit,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: earnings.totalProfit >= 0
                      ? AppColors.success
                      : AppColors.alert,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
