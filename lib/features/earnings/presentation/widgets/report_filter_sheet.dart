import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/report_filter.dart';

/// A channel or product the filter can pick, by id and name.
typedef FilterOption = ({int id, String name});

/// Picks which orders a report counts. Returns null when dismissed.
Future<ReportFilter?> showReportFilterSheet(
  BuildContext context, {
  required ReportFilter current,
  required List<FilterOption> channels,
  required List<FilterOption> products,
}) {
  return showAppSheet<ReportFilter>(
    context: context,
    title: context.l10n.earningsFilterTitle,
    subtitle: context.l10n.earningsFilterSubtitle,
    builder: (_) => ReportFilterForm(
        current: current, channels: channels, products: products),
  );
}

/// Short labels for the filters that are on, for chips under the period.
/// Each comes with the filter it would leave if removed.
List<(String, ReportFilter)> describeFilter(
  ReportFilter f, {
  required AppLocalizations l10n,
  required Map<int, String> channelNames,
  required Map<int, String> productNames,
}) {
  String names(Set<int> ids, Map<int, String> all, String noun,
          String Function(int) many) =>
      ids.length == 1 ? all[ids.first] ?? noun : many(ids.length);
  return [
    if (f.channelIds.isNotEmpty)
      (
        names(f.channelIds, channelNames, l10n.earningsChipChannel,
            l10n.earningsChipChannels),
        f.copyWith(channelIds: const {})
      ),
    if (f.productIds.isNotEmpty)
      (
        names(f.productIds, productNames, l10n.earningsChipProduct,
            l10n.earningsChipProducts),
        f.copyWith(productIds: const {})
      ),
    if (f.statuses.isNotEmpty)
      (
        f.statuses.length == 1
            ? (f.statuses.first == OrderStatus.packed
                ? l10n.earningsChipPackedOnly
                : l10n.earningsChipShippedOnly)
            : l10n.earningsChipPackedOrShipped,
        f.copyWith(statuses: const {})
      ),
    if (f.payment != PaymentFilter.any)
      (
        f.payment == PaymentFilter.paid
            ? l10n.earningsPaid
            : l10n.earningsUnpaid,
        f.copyWith(payment: PaymentFilter.any)
      ),
    if (f.discount != Presence.any)
      (
        f.discount == Presence.with_
            ? l10n.earningsWithDiscount
            : l10n.earningsNoDiscount,
        f.copyWith(discount: Presence.any)
      ),
    if (f.tax != Presence.any)
      (
        f.tax == Presence.with_ ? l10n.earningsWithTax : l10n.earningsNoTax,
        f.copyWith(tax: Presence.any)
      ),
    if (f.minTotal != null || f.maxTotal != null)
      (
        switch ((f.minTotal, f.maxTotal)) {
          (final min?, final max?) => l10n.earningsChipRange(
              CurrencyFormatter.formatShort(min),
              CurrencyFormatter.formatShort(max)),
          (final min?, null) =>
            l10n.earningsChipAndUp(CurrencyFormatter.formatShort(min)),
          (null, final max?) =>
            l10n.earningsChipUpTo(CurrencyFormatter.formatShort(max)),
          _ => '',
        },
        f.copyWith(clearMinTotal: true, clearMaxTotal: true)
      ),
  ];
}

/// The body of [showReportFilterSheet]; public so it can be tested alone.
class ReportFilterForm extends StatefulWidget {
  final ReportFilter current;
  final List<FilterOption> channels;
  final List<FilterOption> products;

  const ReportFilterForm({
    super.key,
    required this.current,
    required this.channels,
    required this.products,
  });

  @override
  State<ReportFilterForm> createState() => _ReportFilterFormState();
}

class _ReportFilterFormState extends State<ReportFilterForm> {
  late ReportFilter _f = widget.current;
  late final _min = TextEditingController(text: _num(widget.current.minTotal));
  late final _max = TextEditingController(text: _num(widget.current.maxTotal));

  static String _num(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Set<T> _toggle<T>(Set<T> set, T value) =>
      set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  void _apply() {
    final min = double.tryParse(_min.text);
    final max = double.tryParse(_max.text);
    Navigator.pop(
      context,
      _f.copyWith(
        minTotal: min,
        clearMinTotal: min == null,
        maxTotal: max,
        clearMaxTotal: max == null,
      ),
    );
  }

  void _clear() {
    _min.clear();
    _max.clear();
    setState(() => _f = ReportFilter.none);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(text,
              style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
        );
    final money = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.channels.isNotEmpty) ...[
          label(l10n.earningsFilterChannel),
          ChoiceChipRow<int>(
            wrap: true,
            options: [
              for (final ch in widget.channels) ChipOption(ch.id, ch.name)
            ],
            isSelected: _f.channelIds.contains,
            onTap: (id) => setState(
                () => _f = _f.copyWith(channelIds: _toggle(_f.channelIds, id))),
          ),
        ],
        if (widget.products.isNotEmpty) ...[
          label(l10n.earningsFilterProducts),
          ChoiceChipRow<int>(
            wrap: true,
            options: [
              for (final p in widget.products) ChipOption(p.id, p.name)
            ],
            isSelected: _f.productIds.contains,
            onTap: (id) => setState(
                () => _f = _f.copyWith(productIds: _toggle(_f.productIds, id))),
          ),
        ],
        label(l10n.earningsFilterStatus),
        ChoiceChipRow<OrderStatus>(
          wrap: true,
          options: [
            ChipOption(OrderStatus.packed, l10n.earningsPacked),
            ChipOption(OrderStatus.shipped, l10n.earningsShipped),
          ],
          isSelected: _f.statuses.contains,
          onTap: (s) => setState(
              () => _f = _f.copyWith(statuses: _toggle(_f.statuses, s))),
        ),
        label(l10n.earningsFilterPayment),
        ChoiceChipRow<PaymentFilter>.single(
          wrap: true,
          options: [
            ChipOption(PaymentFilter.any, l10n.earningsAny),
            ChipOption(PaymentFilter.paid, l10n.earningsPaid),
            ChipOption(PaymentFilter.unpaid, l10n.earningsUnpaid),
          ],
          selected: _f.payment,
          onSelected: (p) => setState(() => _f = _f.copyWith(payment: p)),
        ),
        label(l10n.earningsFilterDiscount),
        ChoiceChipRow<Presence>.single(
          wrap: true,
          options: [
            ChipOption(Presence.any, l10n.earningsAny),
            ChipOption(Presence.with_, l10n.earningsWithDiscount),
            ChipOption(Presence.without, l10n.earningsNoDiscount),
          ],
          selected: _f.discount,
          onSelected: (p) => setState(() => _f = _f.copyWith(discount: p)),
        ),
        label(l10n.earningsFilterTax),
        ChoiceChipRow<Presence>.single(
          wrap: true,
          options: [
            ChipOption(Presence.any, l10n.earningsAny),
            ChipOption(Presence.with_, l10n.earningsWithTax),
            ChipOption(Presence.without, l10n.earningsNoTax),
          ],
          selected: _f.tax,
          onSelected: (p) => setState(() => _f = _f.copyWith(tax: p)),
        ),
        label(l10n.earningsFilterTotal),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _min,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: money,
                decoration: InputDecoration(
                    labelText: l10n.earningsFilterFrom,
                    prefixText: '${CurrencyFormatter.symbol} '),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _max,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: money,
                decoration: InputDecoration(
                    labelText: l10n.earningsFilterTo,
                    prefixText: '${CurrencyFormatter.symbol} '),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(
                onPressed: _clear, child: Text(l10n.earningsFilterClear)),
            const Spacer(),
            FilledButton(
                onPressed: _apply, child: Text(l10n.earningsFilterShow)),
          ],
        ),
      ],
    );
  }
}
