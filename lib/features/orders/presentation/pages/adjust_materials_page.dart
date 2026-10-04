import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../domain/entities/order_material.dart';
import '../bloc/order_detail_bloc.dart';
import '../bloc/order_detail_event.dart';

/// Record what was actually used. Anything over plan counts as waste.
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
  static const _wasteReasons = ['Cutting', 'Defect', 'Miscount', 'Other'];

  late final Map<int, int> _actual = {
    for (final m in widget.materials) m.materialId: m.actualQuantity,
  };
  late final Map<int, String?> _reasons = {
    for (final m in widget.materials) m.materialId: m.wasteReason,
  };

  double get _plannedCost => widget.materials
      .fold(0, (sum, m) => sum + m.plannedQuantity * m.unitCost);

  double get _actualCost => widget.materials.fold(
      0,
      (sum, m) =>
          sum + (_actual[m.materialId] ?? m.actualQuantity) * m.unitCost);

  void _save() {
    final updated = [
      for (final m in widget.materials)
        () {
          final actual = _actual[m.materialId] ?? m.actualQuantity;
          final waste = actual - m.plannedQuantity;
          return OrderMaterialInput(
            materialId: m.materialId,
            materialName: m.materialName,
            plannedQuantity: m.plannedQuantity,
            actualQuantity: actual,
            wasteQuantity: waste > 0 ? waste : 0,
            wasteReason: waste > 0 ? (_reasons[m.materialId] ?? 'Other') : null,
            unitCost: m.unitCost,
          );
        }(),
    ];
    context.read<OrderDetailBloc>().add(
          AdjustMaterials(orderId: widget.orderId, materials: updated),
        );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final delta = _actualCost - _plannedCost;
    return Scaffold(
      appBar: AppBar(title: const Text('Materials used')),
      body: ListView(
        padding: AppSpacing.page.copyWith(top: 4),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Record what you actually used. Anything over plan counts as waste '
              'and comes out of this order\'s profit.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: c.muted, fontSize: 13),
            ),
          ),
          for (final m in widget.materials) ...[
            _MaterialAdjustCard(
              material: m,
              actual: _actual[m.materialId] ?? m.actualQuantity,
              reason: _reasons[m.materialId],
              reasons: _wasteReasons,
              onActualChanged: (v) => setState(() => _actual[m.materialId] = v),
              onReasonChanged: (r) =>
                  setState(() => _reasons[m.materialId] = r),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
      bottomNavigationBar: BottomActionBar(children: [
        BarTotal(
          label: 'Materials',
          value: CurrencyFormatter.format(_actualCost),
          trailing: delta.abs() < 0.005
              ? null
              : Text(
                  '${delta > 0 ? '+' : '−'}${CurrencyFormatter.format(delta.abs())}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: delta > 0 ? c.alert : c.go,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ]),
    );
  }
}

class _MaterialAdjustCard extends StatelessWidget {
  final OrderMaterial material;
  final int actual;
  final String? reason;
  final List<String> reasons;
  final ValueChanged<int> onActualChanged;
  final ValueChanged<String> onReasonChanged;

  const _MaterialAdjustCard({
    required this.material,
    required this.actual,
    required this.reason,
    required this.reasons,
    required this.onActualChanged,
    required this.onReasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final waste = actual - material.plannedQuantity;
    final saved = -waste;
    return AppCard(
      borderColor: waste > 0 ? c.alert.withValues(alpha: 0.5) : null,
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
                      material.materialName,
                      style: AppTextStyles.bodyLarge.copyWith(color: c.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Planned ${material.plannedQuantity} · '
                      '${CurrencyFormatter.format(material.unitCost)} each',
                      style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                    ),
                  ],
                ),
              ),
              StepperInput(
                value: actual,
                min: 0,
                max: material.plannedQuantity * 3 + 10,
                onChanged: (v) => onActualChanged(v.toInt()),
              ),
            ],
          ),
          if (waste > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '+$waste waste · ${CurrencyFormatter.format(waste * material.unitCost)}',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: c.alert,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                const Spacer(),
                Text('Why?',
                    style: AppTextStyles.bodySmall.copyWith(color: c.muted)),
              ],
            ),
            const SizedBox(height: 8),
            ChoiceChipRow<String>(
              wrap: true,
              options: [for (final r in reasons) ChipOption(r, r)],
              isSelected: (r) => r == reason,
              onTap: onReasonChanged,
              selectedColor: c.alertSoft,
              selectedForeground: c.alert,
            ),
          ] else if (saved > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$saved fewer than planned',
              style: AppTextStyles.bodySmall.copyWith(
                  color: c.go, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
