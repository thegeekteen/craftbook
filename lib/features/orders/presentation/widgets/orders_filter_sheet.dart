import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../l10n/gen/app_localizations.dart';

/// Which orders on the Orders tab to show by payment.
enum OrderPaymentFilter {
  any,
  unpaid,
  paid;

  /// The option's name in the app's language.
  String labelOf(AppLocalizations l10n) => switch (this) {
        any => l10n.ordersPaymentAny,
        unpaid => l10n.ordersPaymentUnpaid,
        paid => l10n.ordersPaymentPaid,
      };
}

/// Picks the Orders tab's payment filter. Returns null when dismissed.
Future<OrderPaymentFilter?> showOrdersFilterSheet(
  BuildContext context, {
  required OrderPaymentFilter current,
  Map<OrderPaymentFilter, int> counts = const {},
}) {
  return showAppSheet<OrderPaymentFilter>(
    context: context,
    title: context.l10n.ordersFilterTitle,
    subtitle: context.l10n.ordersFilterSubtitle,
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
        Text(context.l10n.ordersFilterPayment,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        ChoiceChipRow<OrderPaymentFilter>.single(
          wrap: true,
          selected: _payment,
          onSelected: (p) => setState(() => _payment = p),
          options: [
            for (final p in OrderPaymentFilter.values)
              ChipOption(p, p.labelOf(context.l10n), count: widget.counts[p]),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(
              onPressed: () =>
                  setState(() => _payment = OrderPaymentFilter.any),
              child: Text(context.l10n.ordersFilterClearAll),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_payment),
              child: Text(context.l10n.ordersFilterShow),
            ),
          ],
        ),
      ],
    );
  }
}
