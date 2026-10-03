import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../domain/entities/order_material.dart';
import '../bloc/order_detail_bloc.dart';
import '../bloc/order_detail_event.dart';

/// Material adjustment page — adjust actual quantities used
class AdjustMaterialsPage extends StatefulWidget {
  final int orderId;
  final List<OrderMaterial> materials;

  const AdjustMaterialsPage({
    super.key,
    required this.orderId,
    required this.materials,
  });

  @override
  State<AdjustMaterialsPage> createState() => _AdjustMaterialsPageState();
}

class _AdjustMaterialsPageState extends State<AdjustMaterialsPage> {
  static const _wasteReasonOptions = [
    'Cutting',
    'Defect',
    'Miscount',
    'Other',
  ];

  late Map<int, int> _actualQuantities;
  late Map<int, String?> _selectedReasons;

  @override
  void initState() {
    super.initState();
    _actualQuantities = {
      for (final m in widget.materials) m.materialId: m.actualQuantity,
    };
    _selectedReasons = {
      for (final m in widget.materials) m.materialId: m.wasteReason,
    };
  }

  double get _totalCost {
    double total = 0;
    for (final m in widget.materials) {
      final actual = _actualQuantities[m.materialId] ?? m.actualQuantity;
      total += actual * m.unitCost;
    }
    return total;
  }

  void _save() {
    final updatedMaterials = widget.materials.map((m) {
      final actual = _actualQuantities[m.materialId] ?? m.actualQuantity;
      final waste = actual - m.plannedQuantity;
      return OrderMaterialInput(
        materialId: m.materialId,
        materialName: m.materialName,
        plannedQuantity: m.plannedQuantity,
        actualQuantity: actual,
        wasteQuantity: waste > 0 ? waste : 0,
        wasteReason: waste > 0 ? _selectedReasons[m.materialId] : null,
        unitCost: m.unitCost,
      );
    }).toList();

    context.read<OrderDetailBloc>().add(
          AdjustMaterials(
            orderId: widget.orderId,
            materials: updatedMaterials,
          ),
        );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust materials'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.materials.length,
              itemBuilder: (context, index) {
                final mat = widget.materials[index];
                final actual = _actualQuantities[mat.materialId]!;
                final waste = actual - mat.plannedQuantity;
                final selectedReason = _selectedReasons[mat.materialId];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paperHigh,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.hair),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mat.materialName,
                                  style: AppTextStyles.bodyLarge
                                      .copyWith(color: AppColors.ink),
                                ),
                                Text(
                                  'Planned: ${mat.plannedQuantity}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          StepperInput(
                            value: actual,
                            min: 0,
                            max: mat.plannedQuantity * 3,
                            onChanged: (val) {
                              setState(() {
                                _actualQuantities[mat.materialId] = val.toInt();
                              });
                            },
                          ),
                        ],
                      ),

                      if (waste > 0) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Waste: $waste pcs',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.alert),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: _wasteReasonOptions.map((reason) {
                            final isSelected = selectedReason == reason;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedReasons[mat.materialId] =
                                      isSelected ? null : reason;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.alertSoft
                                      : AppColors.paper,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.alert
                                        : AppColors.hair,
                                  ),
                                ),
                                child: Text(
                                  reason,
                                  style: AppTextStyles.monoLabel.copyWith(
                                    color: isSelected
                                        ? AppColors.alert
                                        : AppColors.muted,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Cost: ',
                              style: AppTextStyles.bodySmall),
                          CurrencyText(
                            amount: actual * mat.unitCost,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.ink),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom bar with total and save
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.paperHigh,
              border: Border(top: BorderSide(color: AppColors.hair)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('TOTAL COST',
                            style: AppTextStyles.monoSection),
                        const SizedBox(height: 2),
                        CurrencyText(
                          amount: _totalCost,
                          style: AppTextStyles.displaySmall
                              .copyWith(color: AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
