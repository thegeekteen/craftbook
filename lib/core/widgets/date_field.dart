import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/text_styles.dart';

/// Tappable date box that opens the date picker. Shows "Wed, Oct 7", or
/// [placeholder] when [value] is null.
class DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String placeholder;

  /// When set and a date is picked, the trailing icon clears it instead.
  final VoidCallback? onCleared;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.placeholder = 'Not set',
    this.onCleared,
  });

  Future<void> _pick(BuildContext context) async {
    final first = firstDate ?? DateTime(2020);
    final last = lastDate ?? DateTime(2100);
    final current = value ?? DateUtils.dateOnly(DateTime.now());
    final initial = current.isBefore(first)
        ? first
        : (current.isAfter(last) ? last : current);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: label.toUpperCase(),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final value = this.value;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.controlAll,
        side: BorderSide(color: c.hair),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: c.muted, fontSize: 11.5),
                    ),
                    const SizedBox(height: 1),
                    if (value == null)
                      Text(
                        placeholder,
                        style:
                            AppTextStyles.bodyMedium.copyWith(color: c.muted),
                      )
                    else
                      Text(
                        DateFormat(value.year == DateTime.now().year
                                ? 'EEE, MMM d'
                                : 'MMM d, y')
                            .format(value),
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: c.ink, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              if (value != null && onCleared != null)
                IconButton(
                  tooltip: 'Clear $label',
                  visualDensity: VisualDensity.compact,
                  onPressed: onCleared,
                  icon: Icon(Icons.close_rounded, size: 18, color: c.muted),
                )
              else
                Icon(Icons.event_rounded, size: 18, color: c.muted),
            ],
          ),
        ),
      ),
    );
  }
}
