import 'package:flutter/material.dart';

import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/choice_chip_row.dart';

/// Which orders on the Orders tab to show by payment.
enum OrderPaymentFilter {
  any('Any'),
  unpaid('Unpaid'),
  paid('Paid');

  final String label;
  const OrderPaymentFilter(this.label);
}

/// Picks the Orders tab's payment filter. Returns null when dismissed.
Future<OrderPaymentFilter?> showOrdersFilterSheet(
  BuildContext context, {
  required OrderPaymentFilter current,
  Map<OrderPaymentFilter, int> counts = const {},
}) {
  return showAppSheet<OrderPaymentFilter>(
    context: context,
    title: 'Filter orders',
    subtitle: 'Works together with the status chips and search.',
    builder: (_) => OrdersFilterForm(current: current, counts: counts),
  );
}

/// The sheet's body, public so it can be tested alone.
class OrdersFilterForm extends StatefulWidget {
  final OrderPaymentFilter current;

  /// How many orders each option would show; an option without one shows
  /// no number.
  final Map<OrderPaymentFilter, int> counts;

  const OrdersFilterForm(
      {super.key, required this.current, this.counts = const {}});

  @override
  State<OrdersFilterForm> createState() => _OrdersFilterFormState();
}

class _OrdersFilterFormState extends State<OrdersFilterForm> {
  late OrderPaymentFilter _payment = widget.current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Payment', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        ChoiceChipRow<OrderPaymentFilter>.single(
          wrap: true,
          selected: _payment,
          onSelected: (p) => setState(() => _payment = p),
          options: [
            for (final p in OrderPaymentFilter.values)
              ChipOption(p, p.label, count: widget.counts[p]),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(
              onPressed: () =>
                  setState(() => _payment = OrderPaymentFilter.any),
              child: const Text('Clear all'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_payment),
              child: const Text('Show'),
            ),
          ],
        ),
      ],
    );
  }
}
