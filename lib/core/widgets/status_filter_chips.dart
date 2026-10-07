import 'package:flutter/material.dart';

import '../../features/orders/domain/entities/order.dart';
import '../../features/orders/presentation/widgets/order_l10n.dart';
import 'choice_chip_row.dart';
import '../utils/l10n_extension.dart';

/// Status filter for Today and the calendars.
///
/// "All" selects every status in [statuses]; tapping a status shows only
/// that status (tap it again to go back to All). Counts are optional.
class StatusFilterChips extends StatelessWidget {
  final Set<OrderStatus> selected;
  final ValueChanged<Set<OrderStatus>> onChanged;
  final Map<OrderStatus, int>? counts;

  /// Statuses offered as chips. Cancelled orders are left off day views:
  /// they no longer need doing, and the Orders tab still lists them.
  final List<OrderStatus> statuses;

  static const dayViewStatuses = [
    OrderStatus.pending,
    OrderStatus.packed,
    OrderStatus.shipped,
  ];

  const StatusFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.counts,
    this.statuses = dayViewStatuses,
  });

  bool get _isAll => statuses.every(selected.contains);

  @override
  Widget build(BuildContext context) {
    final total = counts?.values.fold<int>(0, (a, b) => a + b);
    return ChoiceChipRow<OrderStatus?>(
      options: [
        ChipOption<OrderStatus?>(null, context.l10n.commonAll, count: total),
        for (final s in statuses)
          ChipOption<OrderStatus?>(s, s.localized(context.l10n),
              count: counts?[s]),
      ],
      isSelected: (s) => s == null ? _isAll : (!_isAll && selected.contains(s)),
      onTap: (s) {
        if (s == null ||
            (!_isAll && selected.length == 1 && selected.contains(s))) {
          onChanged(Set<OrderStatus>.from(statuses));
        } else {
          onChanged({s});
        }
      },
    );
  }
}
