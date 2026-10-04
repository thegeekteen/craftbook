import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/summary_board.dart';
import '../../domain/entities/profit_trend.dart';
import '../bloc/earnings_bloc.dart';
import '../bloc/earnings_event.dart';
import '../bloc/earnings_state.dart';
import '../widgets/profit_trend_chart.dart';

enum _Range { week, month, year }

/// Money: profit for a week, month or year, where it came from, and waste.
class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EarningsBloc>(),
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
  _Range _range = _Range.week;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  TrendGranularity get _granularity =>
      _range == _Range.year ? TrendGranularity.month : TrendGranularity.day;

  DateTimeRange get _period {
    final now = DateTime.now();
    switch (_range) {
      case _Range.week:
        final start = app_date.DateUtils.startOfWeek(now)
            .add(Duration(days: 7 * _offset));
        return DateTimeRange(
            start: start, end: app_date.DateUtils.endOfWeek(start));
      case _Range.month:
        final start = DateTime(now.year, now.month + _offset, 1);
        return DateTimeRange(
            start: start, end: app_date.DateUtils.endOfMonth(start));
      case _Range.year:
        final year = now.year + _offset;
        return DateTimeRange(
            start: DateTime(year), end: DateTime(year, 12, 31, 23, 59, 59));
    }
  }

  String get _periodLabel {
    final p = _period;
    if (_offset == 0) {
      return switch (_range) {
        _Range.week => 'This week',
        _Range.month => 'This month',
        _Range.year => 'This year',
      };
    }
    if (_offset == -1 && _range != _Range.year) {
      return _range == _Range.week ? 'Last week' : 'Last month';
    }
    return switch (_range) {
      _Range.week => p.start.month == p.end.month
          ? '${DateFormat('MMM d').format(p.start)} – ${p.end.day}'
          : '${DateFormat('MMM d').format(p.start)} – ${DateFormat('MMM d').format(p.end)}',
      _Range.month => DateFormat('MMMM y').format(p.start),
      _Range.year => '${p.start.year}',
    };
  }

  String get _periodDetail {
    final p = _period;
    return switch (_range) {
      _Range.week =>
        '${DateFormat('MMM d').format(p.start)} – ${DateFormat('MMM d').format(p.end)}',
      _Range.month => DateFormat('MMMM y').format(p.start),
      _Range.year => '${p.start.year}',
    };
  }

  void _load() {
    final p = _period;
    context.read<EarningsBloc>().add(
          LoadEarnings(
              startDate: p.start, endDate: p.end, granularity: _granularity),
        );
  }

  void _setRange(_Range r) {
    setState(() {
      _range = r;
      _offset = 0;
    });
    _load();
  }

  void _shift(int delta) {
    setState(() => _offset += delta);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money')),
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
      materials: sum.totalMaterialCost,
      fees: sum.totalChannelFees,
      shipping: sum.totalShippingCost,
    );
    final orders = sum.orderCount;

    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView(
        padding: AppSpacing.page.copyWith(top: 4),
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<_Range>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: _Range.week, label: Text('Week')),
                ButtonSegment(value: _Range.month, label: Text('Month')),
                ButtonSegment(value: _Range.year, label: Text('Year')),
              ],
              selected: {_range},
              onSelectionChanged: (v) => _setRange(v.first),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => _shift(-1),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(_periodLabel,
                        style: AppTextStyles.bodyLarge.copyWith(color: c.ink)),
                    if (_offset == 0 ||
                        (_offset == -1 && _range != _Range.year))
                      Text(_periodDetail,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: c.muted, fontSize: 11.5)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Next',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _offset >= 0 ? null : () => _shift(1),
              ),
            ],
          ),
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
                      buckets: s.trend, granularity: _granularity),
                ),
                const SizedBox(height: 12),
                if (orders == 0)
                  AppCard(
                    child: Text(
                      'No packed or shipped orders in this period. Profit counts once an order is packed.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: c.muted, fontSize: 13),
                    ),
                  )
                else ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MoneyBreakdown(parts: parts),
                        const SizedBox(height: 4),
                        Text(
                          '${(parts.margin * 100).round()}% of sales is profit',
                          style:
                              AppTextStyles.bodySmall.copyWith(color: c.muted),
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
                            '${p.quantitySold} sold · ${CurrencyFormatter.formatShort(p.totalSales)} sales',
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
                            RouteNames.productEarningsPath(
                                p.productId, s.startDate, s.endDate),
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
                                '${w.quantity} ${w.quantity == 1 ? 'pc' : 'pcs'} wasted'),
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
