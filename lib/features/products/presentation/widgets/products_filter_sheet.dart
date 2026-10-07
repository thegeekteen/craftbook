import 'package:flutter/material.dart';

import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../product_list_filter.dart';

/// Picks the Products tab's filter. Returns null when dismissed.
Future<ProductListFilter?> showProductsFilterSheet(
  BuildContext context, {
  required ProductListFilter current,
  required ProductCatalogueView view,
}) {
  return showAppSheet<ProductListFilter>(
    context: context,
    title: 'Filter products',
    subtitle: 'Works together with search.',
    builder: (_) => ProductsFilterForm(current: current, view: view),
  );
}

/// The sheet's body, public so it can be tested alone.
class ProductsFilterForm extends StatefulWidget {
  final ProductListFilter current;

  /// Answers each option's count, given what the other group has picked.
  final ProductCatalogueView view;

  const ProductsFilterForm(
      {super.key, required this.current, required this.view});

  @override
  State<ProductsFilterForm> createState() => _ProductsFilterFormState();
}

class _ProductsFilterFormState extends State<ProductsFilterForm> {
  late ProductListFilter _filter = widget.current;

  @override
  Widget build(BuildContext context) {
    final view = widget.view;
    final label = Theme.of(context).textTheme.bodyMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Type', style: label),
        const SizedBox(height: 8),
        ChoiceChipRow<ProductTypeFilter>.single(
          wrap: true,
          selected: _filter.type,
          onSelected: (t) =>
              setState(() => _filter = _filter.copyWith(type: t)),
          options: [
            for (final t in ProductTypeFilter.values)
              ChipOption(t, t.label,
                  count: view.count(_filter.copyWith(type: t))),
          ],
        ),
        const SizedBox(height: 16),
        Text('Stock', style: label),
        const SizedBox(height: 8),
        ChoiceChipRow<ProductStockFilter>.single(
          wrap: true,
          selected: _filter.stock,
          onSelected: (s) =>
              setState(() => _filter = _filter.copyWith(stock: s)),
          options: [
            for (final s in ProductStockFilter.values)
              if ((s != ProductStockFilter.short || view.hasShort) &&
                  (s != ProductStockFilter.archived || view.hasArchived))
                ChipOption(s, s.label,
                    count: view.count(_filter.copyWith(stock: s))),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _filter = ProductListFilter.none),
              child: const Text('Clear all'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_filter),
              child: const Text('Show'),
            ),
          ],
        ),
      ],
    );
  }
}
