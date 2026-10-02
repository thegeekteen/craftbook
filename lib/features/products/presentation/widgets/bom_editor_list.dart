import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../domain/entities/bom_item.dart';

/// BOM item list widget for the product editor
class BomEditorList extends StatelessWidget {
  final List<BomItem> items;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<int> onRemoved;
  final int Function(BomItem) getItemId;

  const BomEditorList({
    super.key,
    required this.items,
    required this.onQuantityChanged,
    required this.onRemoved,
    required this.getItemId,
  });

  double get totalCost =>
      items.fold(0.0, (sum, item) => sum + item.lineCost);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.paperHigh,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.hair),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined,
                  color: AppColors.muted, size: 32),
              const SizedBox(height: 8),
              Text(
                'No materials added yet',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.paperHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.hair),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.materialName,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.ink),
                      ),
                      CurrencyText(
                        amount: item.materialUnitCost,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                StepperInput(
                  value: item.quantityRequired,
                  min: 1,
                  max: 999,
                  onChanged: (val) {
                    // The parent must handle this by updating the item
                    onQuantityChanged(getItemId(item));
                  },
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CurrencyText(
                      amount: item.lineCost,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.coin),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => onRemoved(getItemId(item)),
                  icon: const Icon(Icons.close, size: 16,
                      color: AppColors.muted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          );
        }),

        // Total
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Total: ',
                  style: AppTextStyles.bodySmall),
              CurrencyText(
                amount: totalCost,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.coin),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
