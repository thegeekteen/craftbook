import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/text_styles.dart';

/// Tappable date box that opens the date picker. Shows "Wed, Oct 7".
class DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _pick(BuildContext context) async {
    final first = firstDate ?? DateTime(2020);
    final last = lastDate ?? DateTime(2100);
    final initial = value.isBefore(first) ? first : (value.isAfter(last) ? last : value);
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
    final sameYear = value.year == DateTime.now().year;
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
                      style: AppTextStyles.bodySmall.copyWith(color: c.muted, fontSize: 11.5),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      DateFormat(sameYear ? 'EEE, MMM d' : 'MMM d, y').format(value),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: c.ink, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.event_rounded, size: 18, color: c.muted),
            ],
          ),
        ),
      ),
    );
  }
}
