import 'package:flutter/material.dart';

import '../../features/orders/domain/entities/order.dart';
import '../../features/orders/presentation/widgets/order_status_ui.dart';
import 'choice_chip_row.dart';

/// Status filter for Today and the calendars.
///
/// "All" selects every status; tapping a status shows only that status
/// (tap it again to go back to All). Counts are optional.
class StatusFilterChips extends StatelessWidget {
  final Set<OrderStatus> selected;
  final ValueChanged<Set<OrderStatus>> onChanged;
  final Map<OrderStatus, int>? counts;

  /// Statuses offered as chips. Cancelled is hidden by default on day views.
  final List<OrderStatus> statuses;

  const StatusFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.counts,
    this.statuses = const [
      OrderStatus.pending,
      OrderStatus.packed,
      OrderStatus.shipped,
      OrderStatus.cancelled,
    ],
  });

  bool get _isAll => statuses.every(selected.contains);

  @override
  Widget build(BuildContext context) {
    final total = counts?.values.fold<int>(0, (a, b) => a + b);
    return ChoiceChipRow<OrderStatus?>(
      options: [
        ChipOption<OrderStatus?>(null, 'All', count: total),
        for (final s in statuses)
          ChipOption<OrderStatus?>(s, s.label, count: counts?[s]),
      ],
      isSelected: (s) => s == null ? _isAll : (!_isAll && selected.contains(s)),
      onTap: (s) {
        if (s == null ||
            (!_isAll && selected.length == 1 && selected.contains(s))) {
          onChanged(Set<OrderStatus>.from(OrderStatus.values));
        } else {
          onChanged({s});
        }
      },
    );
  }
}
