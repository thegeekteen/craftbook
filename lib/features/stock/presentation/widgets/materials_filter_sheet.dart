import 'package:flutter/material.dart';

import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../material_list_filter.dart';

/// Picks the Materials tab's filter. Returns null when dismissed.
Future<MaterialStockFilter?> showMaterialsFilterSheet(
  BuildContext context, {
  required MaterialStockFilter current,
  required MaterialCatalogueView view,
}) {
  return showAppSheet<MaterialStockFilter>(
    context: context,
    title: 'Filter materials',
    subtitle: 'Works together with search.',
    builder: (_) => MaterialsFilterForm(current: current, view: view),
  );
}

/// The sheet's body, public so it can be tested alone.
class MaterialsFilterForm extends StatefulWidget {
  final MaterialStockFilter current;

  /// Answers each option's count.
  final MaterialCatalogueView view;

  const MaterialsFilterForm(
      {super.key, required this.current, required this.view});

  @override
  State<MaterialsFilterForm> createState() => _MaterialsFilterFormState();
}

class _MaterialsFilterFormState extends State<MaterialsFilterForm> {
  late MaterialStockFilter _stock = widget.current;

  @override
  Widget build(BuildContext context) {
    final view = widget.view;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Stock', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        ChoiceChipRow<MaterialStockFilter>.single(
          wrap: true,
          selected: _stock,
          onSelected: (s) => setState(() => _stock = s),
          options: [
            for (final s in MaterialStockFilter.values)
              if (s != MaterialStockFilter.archived || view.hasArchived)
                ChipOption(s, s.label, count: view.count(s)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _stock = MaterialStockFilter.any),
              child: const Text('Clear all'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_stock),
              child: const Text('Show'),
            ),
          ],
        ),
      ],
    );
  }
}
