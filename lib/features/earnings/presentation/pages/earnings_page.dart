import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/summary_board.dart';
import '../../../../core/error/result.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../orders/presentation/bloc/receivables_cubit.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/domain/usecases/get_channels.dart';
import '../../../settings/presentation/bloc/tax_settings_cubit.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_period.dart';
import '../widgets/report_filter_sheet.dart';
import '../bloc/earnings_bloc.dart';
import '../bloc/earnings_event.dart';
import '../bloc/earnings_state.dart';
import '../widgets/profit_trend_chart.dart';

/// Reports: profit for a week, month, year or custom range, where it came
/// from, and waste.
class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<EarningsBloc>()),
        // Waiting for payment is all-time, so it isn't part of the period.
        BlocProvider(create: (_) => getIt<ReceivablesCubit>()..load()),
      ],
      child: const _EarningsView(),
    );
  }
}

class _EarningsView extends StatefulWidget {
  const _EarningsView();

  @override
  State<_EarningsView> createState() => _EarningsViewState();
}

class _EarningsViewState extends State<_EarningsView> {
  ReportPeriod _period = const ReportPeriod(ReportRange.week);
  ReportFilter _filter = ReportFilter.none;
  List<FilterOption> _channels = const [];
  List<FilterOption> _products = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadFilterOptions();
  }

  /// Every channel and product, archived ones too, since past orders use
  /// them.
  Future<void> _loadFilterOptions() async {
    final channels = await getIt<GetChannels>()();
    final products = await getIt<ProductRepository>().getAllProducts();
    if (!mounted) return;
    setState(() {
      if (channels case Success(:final value)) {
        _channels = [for (final c in value) (id: c.id!, name: c.name)];
      }
      if (products case Success(:final value)) {
        _products = [for (final p in value) (id: p.id!, name: p.name)]
          ..sort((a, b) => a.name.compareTo(b.name));
      }
    });
  }

  Future<void> _openFilter() async {
    final picked = await showReportFilterSheet(
      context,
      current: _filter,
      channels: _channels,
      products: _products,
    );
    if (picked == null || !mounted) return;
    _setFilter(picked);
  }

  void _setFilter(ReportFilter filter) {
    setState(() => _filter = filter);
    _load();
  }

  Future<void> _reload() async {
    _load();
    await context.read<ReceivablesCubit>().load();
  }

  void _load() {
    final now = DateTime.now();
    final p = _period.resolve(now);
    context.read<EarningsBloc>().add(
          LoadEarnings(
            startDate: p.start,
            endDate: p.end,
            granularity: _period.granularity(now),
            filter: _filter,
          ),
        );
  }

  Future<void> _setRange(ReportRange r) async {
    if (r == ReportRange.custom) return _pickCustom();
    setState(() => _period = ReportPeriod(r));
    _load();
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final current = _period.resolve(now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: app_date.DateUtils.endOfDay(now),
      initialDateRange: _period.isCustom
          ? DateTimeRange(start: current.start, end: current.end)
          : null,
      helpText: 'Report on',
      saveText: 'Show',
    );
    if (picked == null || !mounted) return;
    setState(() => _period = ReportPeriod.custom(picked.start, picked.end));
    _load();
  }

  void _shift(int delta) {
    setState(() => _period = _period.shifted(delta));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            onPressed: _openFilter,
            icon: Badge(
              isLabelVisible: !_filter.isEmpty,
              label: Text('${_filter.activeCount}'),
              child: const Icon(Icons.filter_list_rounded),
            ),
          ),
        ],
      ),
      body: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) {
          return switch (state) {
            EarningsLoaded() => _buildLoaded(state),
            EarningsError(:final message) =>
              Center(child: ErrorState(message: message, onRetry: _load)),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }

  Widget _buildLoaded(EarningsLoaded s) {
    final c = context.colors;
    final sum = s.summary;
    final parts = MoneyParts(
      sales: sum.totalSales,
      discount: sum.totalDiscount,
      includedTax: sum.totalIncludedTax,
      addedTax: sum.totalAddedTax,
      materials: sum.totalMaterialCost,
      fees: sum.totalChannelFees,
      shipping: sum.totalShippingCost,
    );
    final orders = sum.orderCount;

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: AppSpacing.page.copyWith(top: 4),
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ReportRange>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ReportRange.week, label: Text('Week')),
                ButtonSegment(value: ReportRange.month, label: Text('Month')),
                ButtonSegment(value: ReportRange.year, label: Text('Year')),
                ButtonSegment(value: ReportRange.custom, label: Text('Custom')),
              ],
              selected: {_period.range},
              // Re-tapping Custom picks a new range.
              onSelectionChanged: (v) => _setRange(v.first),
            ),
          ),
          const SizedBox(height: 6),
          _PeriodBar(
            period: _period,
            onShift: _shift,
            onPickCustom: _pickCustom,
          ),
          if (!_filter.isEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final (label, without) in describeFilter(
                  _filter,
                  channelNames: {for (final c in _channels) c.id: c.name},
                  productNames: {for (final p in _products) p.id: p.name},
                ))
                  AppChip(
                    label: label,
                    trailingIcon: Icons.close_rounded,
                    selected: true,
                    onTap: () => _setFilter(without),
                  ),
                TextButton(
                  onPressed: () => _setFilter(ReportFilter.none),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 6),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: s.isRefreshing ? 0.55 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SummaryBoard(
                  label:
                      'Net profit · $orders ${orders == 1 ? 'order' : 'orders'}',
                  value: CurrencyFormatter.formatShort(parts.profit),
                  valueColor: parts.profit < 0 ? c.alert : null,
                  child: ProfitTrendChart(
                      buckets: s.trend,
                      granularity: _period.granularity(DateTime.now())),
                ),
                const SizedBox(height: 12),
                const _WaitingForPaymentCard(),
                if (orders == 0)
                  AppCard(
                    child: Text(
                      _filter.isEmpty
                          ? 'No packed or shipped orders in this period. Profit counts once an order is packed.'
                          : 'No packed or shipped orders in this period match the filter.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: c.muted, fontSize: 13),
                    ),
                  )
                else ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MoneyBreakdown(
                          parts: parts,
                          taxLabel: getIt<TaxSettingsCubit>().state.label,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(parts.margin * 100).round()}% of sales is profit',
                          style:
                              AppTextStyles.bodySmall.copyWith(color: c.muted),
                        ),
                        if (sum.unpaidCount > 0)
                          Text(
                            '${CurrencyFormatter.format(sum.unpaidTotal)} of '
                            'it is still unpaid (${sum.unpaidCount} '
                            '${sum.unpaidCount == 1 ? 'order' : 'orders'})',
                            style:
                                AppTextStyles.bodySmall.copyWith(color: c.warn),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SectionLabel('By product · ${s.productEarnings.length}'),
                  const SizedBox(height: 8),
                  AppCard.flush(
                    child: CardList(children: [
                      for (final p in s.productEarnings)
                        CardRow(
                          title: Text(p.productName),
                          subtitle: Text(
                            '${QuantityFormatter.withUnit(p.quantitySold, p.unit)} sold'
                            ' · ${CurrencyFormatter.formatShort(p.totalSales)} sales',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                CurrencyFormatter.formatShort(p.totalProfit),
                                style: AppTextStyles.amount.copyWith(
                                  fontSize: 15.5,
                                  color: p.totalProfit >= 0 ? c.go : c.alert,
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: c.muted, size: 20),
                            ],
                          ),
                          onTap: () => context.push(
                            RouteNames.productReportPath(
                                p.productId, s.startDate, s.endDate),
                            extra: _filter,
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 4),
                  SectionLabel(
                    s.wasteSummary.totalWasteCost > 0
                        ? 'Waste · ${CurrencyFormatter.format(s.wasteSummary.totalWasteCost)}'
                        : 'Waste',
                  ),
                  const SizedBox(height: 8),
                  if (s.wasteSummary.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        'No waste recorded in this period.',
                        style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                      ),
                    )
                  else
                    AppCard.flush(
                      child: CardList(children: [
                        for (final w in s.wasteSummary.items)
                          CardRow(
                            title: Text(w.materialName),
                            subtitle: Text(
                                '${QuantityFormatter.withUnit(w.quantity, w.unit)} wasted'),
                            trailing: Text(
                              '−${CurrencyFormatter.format(w.cost)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: c.alert,
                                fontWeight: FontWeight.w600,
                                fontFeatures:
                                    AppTextStyles.tabular.fontFeatures,
                              ),
                            ),
                          ),
                      ]),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Previous / label / next for week, month and year; for a custom range the
/// label opens the picker again instead.
class _PeriodBar extends StatelessWidget {
  final ReportPeriod period;
  final ValueChanged<int> onShift;
  final VoidCallback onPickCustom;

  const _PeriodBar({
    required this.period,
    required this.onShift,
    required this.onPickCustom,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final detail = period.detail(now);
    final label = Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(period.label(now),
                  style: AppTextStyles.bodyLarge.copyWith(color: c.ink)),
            ),
            if (period.isCustom) ...[
              const SizedBox(width: 6),
              Icon(Icons.edit_calendar_outlined, size: 16, color: c.muted),
            ],
          ],
        ),
        if (detail != null)
          Text(detail,
              style: AppTextStyles.bodySmall
                  .copyWith(color: c.muted, fontSize: 11.5)),
      ],
    );
    if (period.isCustom) {
      return InkWell(
        borderRadius: AppRadii.controlAll,
        onTap: onPickCustom,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: label,
        ),
      );
    }
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => onShift(-1),
        ),
        Expanded(child: label),
        IconButton(
          tooltip: 'Next',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: period.canGoForward ? () => onShift(1) : null,
        ),
      ],
    );
  }
}

/// All-time money customers still owe, with a way to the list. Hidden
/// when everyone has paid.
class _WaitingForPaymentCard extends StatelessWidget {
  const _WaitingForPaymentCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BlocBuilder<ReceivablesCubit, ReceivablesState>(
      builder: (context, state) {
        if (state is! ReceivablesLoaded || state.receivables.isEmpty) {
          return const SizedBox.shrink();
        }
        final r = state.receivables;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            onTap: () async {
              await context.push(RouteNames.receivables);
              if (context.mounted) {
                await context.read<ReceivablesCubit>().load();
              }
            },
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: c.warn),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Waiting for payment',
                          style:
                              AppTextStyles.bodyLarge.copyWith(color: c.ink)),
                      Text(
                        '${r.orderCount} ${r.orderCount == 1 ? 'order' : 'orders'}'
                        ' · ${r.groups.length} '
                        '${r.groups.length == 1 ? 'customer' : 'customers'}',
                        style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.formatShort(r.total),
                  style: AppTextStyles.amount
                      .copyWith(fontSize: 17, color: c.warn),
                ),
                Icon(Icons.chevron_right_rounded, color: c.muted),
              ],
            ),
          ),
        );
      },
    );
  }
}
