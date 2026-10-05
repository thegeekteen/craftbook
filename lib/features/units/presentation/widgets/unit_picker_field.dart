import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../domain/entities/unit_of_measure.dart';
import '../../domain/repositories/unit_repository.dart';

/// A form row that picks the unit a material or product is counted in.
///
/// Reads the list when tapped rather than holding one, so units added on the
/// Units screen are offered the next time the field is opened.
class UnitPickerField extends StatelessWidget {
  final String label;
  final UnitOfMeasure? unit;
  final ValueChanged<UnitOfMeasure> onChanged;

  const UnitPickerField({
    super.key,
    required this.label,
    required this.unit,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final result = await getIt<UnitRepository>().getUnits();
    if (!context.mounted) return;
    final units = switch (result) {
      Success(:final value) => value,
      Error() => const <UnitOfMeasure>[],
    };
    if (units.isEmpty) return;

    final picked = await showAppSheet<UnitOfMeasure>(
      context: context,
      title: label,
      subtitle: 'Every number for this is written with it.',
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final u in units)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(u.label),
              trailing: u.id == unit?.id
                  ? Icon(Icons.check_rounded, color: sheetContext.colors.go)
                  : null,
              onTap: () => Navigator.pop(sheetContext, u),
            ),
        ],
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: () => _pick(context),
      child: InputDecorator(
        isEmpty: false,
        decoration: InputDecoration(
          labelText: label,
          helperText: 'Add more in More → Units of measure',
          suffixIcon: const Icon(Icons.unfold_more_rounded),
        ),
        child: Text(
          unit?.label ?? '—',
          style: AppTextStyles.bodyLarge.copyWith(
            color: unit == null ? c.muted : c.ink,
          ),
        ),
      ),
    );
  }
}
