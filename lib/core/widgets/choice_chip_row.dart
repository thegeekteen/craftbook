import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/text_styles.dart';

/// One option in a [ChoiceChipRow].
class ChipOption<T> {
  final T value;
  final String label;
  final int? count;

  const ChipOption(this.value, this.label, {this.count});
}

/// The single chip style: a stadium pill, ink-filled when selected, with an
/// optional count. Scrolls horizontally and bleeds to the screen edge so
/// the first chip lines up with the page gutter.
class ChoiceChipRow<T> extends StatelessWidget {
  final List<ChipOption<T>> options;
  final bool Function(T value) isSelected;
  final ValueChanged<T> onTap;

  /// Wrap onto multiple lines instead of scrolling (for forms).
  final bool wrap;

  /// Colour for the selected state; defaults to ink.
  final Color? selectedColor;
  final Color? selectedForeground;

  /// Inner padding of the scroll view, so chips can scroll edge to edge
  /// while resting on the page gutter.
  final EdgeInsetsGeometry padding;

  const ChoiceChipRow({
    super.key,
    required this.options,
    required this.isSelected,
    required this.onTap,
    this.wrap = false,
    this.selectedColor,
    this.selectedForeground,
    this.padding = EdgeInsets.zero,
  });

  /// Convenience for single-select.
  factory ChoiceChipRow.single({
    Key? key,
    required List<ChipOption<T>> options,
    required T selected,
    required ValueChanged<T> onSelected,
    bool wrap = false,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return ChoiceChipRow<T>(
      key: key,
      options: options,
      isSelected: (v) => v == selected,
      onTap: onSelected,
      wrap: wrap,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final o in options)
        AppChip(
          label: o.label,
          count: o.count,
          selected: isSelected(o.value),
          onTap: () => onTap(o.value),
          selectedColor: selectedColor,
          selectedForeground: selectedForeground,
        ),
    ];
    if (wrap) {
      return Wrap(spacing: 8, runSpacing: 8, children: chips);
    }
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: padding,
        child: Row(
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              chips[i],
            ],
          ],
        ),
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? selectedForeground;

  const AppChip({
    super.key,
    required this.label,
    this.count,
    required this.selected,
    this.onTap,
    this.selectedColor,
    this.selectedForeground,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = selected ? (selectedColor ?? c.ink) : c.surface;
    final fg = selected ? (selectedForeground ?? c.paper) : c.ink;
    final border = selected ? (selectedColor ?? c.ink) : c.hair;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.pillAll,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadii.pillAll,
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: AppTextStyles.monoTag.copyWith(
                      fontSize: 11,
                      color: fg.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
