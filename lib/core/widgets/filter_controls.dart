import 'package:flutter/material.dart';

import 'choice_chip_row.dart';

/// The app-bar Filter button that opens a page's filter sheet, with a badge
/// counting how many filters are on.
class FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onPressed;

  const FilterButton(
      {super.key, required this.activeCount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Filter',
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: activeCount > 0,
        label: Text('$activeCount'),
        child: const Icon(Icons.filter_list_rounded),
      ),
    );
  }
}

/// One removable chip under a page's search for a filter that's on.
typedef ActiveFilter = (String label, VoidCallback onRemove);

/// The filters that are on, each a chip that removes itself when tapped,
/// so a filtered list never hides why it's short. Renders nothing when no
/// filter is on.
class ActiveFilterChips extends StatelessWidget {
  final List<ActiveFilter> filters;

  /// Clears every filter; offered once there's more than one to remove.
  final VoidCallback? onClearAll;

  final EdgeInsetsGeometry padding;

  const ActiveFilterChips({
    super.key,
    required this.filters,
    this.onClearAll,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final (label, onRemove) in filters)
              AppChip(
                label: label,
                selected: true,
                trailingIcon: Icons.close_rounded,
                onTap: onRemove,
              ),
            if (onClearAll != null && filters.length > 1)
              TextButton(onPressed: onClearAll, child: const Text('Clear')),
          ],
        ),
      ),
    );
  }
}
