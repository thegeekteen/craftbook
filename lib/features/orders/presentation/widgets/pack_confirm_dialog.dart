import 'package:flutter/material.dart' hide Material;

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../domain/entities/order_material.dart';
import '../../../stock/domain/entities/material.dart';

/// Confirmation dialog for packing an order
/// Shows before → after stock per material
class PackConfirmDialog extends StatelessWidget {
  final List<OrderMaterial> orderMaterials;
  final List<Material> currentMaterials;

  const PackConfirmDialog({
    super.key,
    required this.orderMaterials,
    required this.currentMaterials,
  });

  static Future<bool> show(
    BuildContext context, {
    required List<OrderMaterial> orderMaterials,
    required List<Material> currentMaterials,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => PackConfirmDialog(
        orderMaterials: orderMaterials,
        currentMaterials: currentMaterials,
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final hasWarnings = _hasWarnings;

    return AlertDialog(
      backgroundColor: AppColors.paperHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Pack order?',
        style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will deduct materials from stock.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 12),

          // Material rows with before/after
          ...orderMaterials.map((om) {
            final material = currentMaterials
                .where((m) => m.id! == om.materialId)
                .firstOrNull;
            final beforeOnHand = material?.quantityOnHand ?? 0;
            final afterOnHand = beforeOnHand - om.actualQuantity;
            final alertLevel = material?.alertLevel ?? 0;
            final willBeLow = afterOnHand <= alertLevel;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.hair),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          om.materialName,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.ink),
                        ),
                      ),
                      if (willBeLow)
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
                  Row(
                    children: [
                      Text(
                        '$beforeOnHand',
                        style: AppTextStyles.monoLabel
                            .copyWith(color: AppColors.muted),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.arrow_forward,
                            size: 12, color: AppColors.muted),
                      ),
                      Text(
                        '$afterOnHand',
                        style: AppTextStyles.monoLabel.copyWith(
                          color: willBeLow ? AppColors.alert : AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(−${om.actualQuantity})',
                        style: AppTextStyles.monoLabel
                            .copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          if (hasWarnings) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.alertSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      size: 16, color: AppColors.alert),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Some materials will drop below alert level',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.alert),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: const Text('Pack & deduct'),
        ),
      ],
    );
  }

  bool get _hasWarnings {
    for (final om in orderMaterials) {
      final material =
          currentMaterials.where((m) => m.id! == om.materialId).firstOrNull;
      if (material != null) {
        final afterOnHand = material.quantityOnHand - om.actualQuantity;
        if (afterOnHand <= material.alertLevel) return true;
      }
    }
    return false;
  }
}
