import 'dart:async';

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
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/inline_banner.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/status_filter_chips.dart';
import '../../../../core/widgets/summary_board.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_list_entry.dart';
import '../../../orders/presentation/widgets/order_card.dart';
import '../../../settings/domain/entities/order_amount_shown.dart';
import '../../../settings/presentation/bloc/order_amount_cubit.dart';
import '../../domain/usecases/get_today_dashboard.dart';
import '../bloc/today_bloc.dart';
import '../bloc/today_event.dart';
import '../bloc/today_state.dart';

/// Today: what to pack, what came in, and what's running out.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TodayBloc>()..add(const LoadToday()),
      child: const _TodayView(),
    );
  }
}

class _TodayView extends StatefulWidget {
  const _TodayView();

  @override
  State<_TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<_TodayView> {
  Set<OrderStatus> _statusFilter = Set.from(OrderStatus.values);

  void _reload() => context.read<TodayBloc>().add(const LoadToday());

  /// Pushes [location] and reloads when the child reports a change.
  Future<void> _open(String location) async {
    final changed = await context.push<bool>(location);
    if (changed == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEEE').format(now).toUpperCase(),
              style: AppTextStyles.monoLabel.copyWith(color: c.muted),
            ),
            Text(DateFormat('MMMM d').format(now)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Calendar',
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => _open(RouteNames.calendarWeek),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<TodayBloc, TodayState>(
        listener: (context, state) {
          if (state is TodayError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return switch (state) {
            TodayLoaded(:final dashboard) => _buildDashboard(dashboard),
            TodayError(:final message) =>
              Center(child: ErrorState(message: message, onRetry: _reload)),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(RouteNames.newOrder),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New order'),
      ),
    );
  }

  Widget _buildDashboard(TodayDashboard d) {
    final c = context.colors;
    bool shown(OrderListEntry e) => _statusFilter.contains(e.order.status);
    final due = d.due.where(shown).toList();
    final placed = d.placedToday.where(shown).toList();

    final counts = <OrderStatus, int>{};
    final seen = <int?>{};
    for (final e in [...d.due, ...d.placedToday]) {
      if (seen.add(e.order.id)) {
        counts[e.order.status] = (counts[e.order.status] ?? 0) + 1;
      }
    }

    final alerts = d.alerts;
    final names = alerts.materialNames.take(2).join(', ');
    final more = alerts.materialNames.length > 2 ? '…' : '';

    return RefreshIndicator(
      onRefresh: () {
        final done = Completer<void>();
        context.read<TodayBloc>().add(LoadToday(done: done));
        return done.future;
      },
      child: ListView(
        padding: AppSpacing.page.copyWith(bottom: AppSpacing.fabClearance),
        children: [
          SummaryBoard(
            label: 'To pack today',
            value: '${d.toPackCount}',
            stats: [
              BoardStat(label: 'New today', value: '${d.placedToday.length}'),
              BoardStat(
                label: 'Overdue',
                value: '${d.overdueCount}',
                labelColor: d.overdueCount > 0 ? c.alert : null,
              ),
              BoardStat(
                label: 'Week profit',
                value: CurrencyFormatter.formatCompact(d.weekProfit),
              ),
            ],
            onTap: () => context.go(RouteNames.orders),
          ),
          if (alerts.hasAlerts) ...[
            const SizedBox(height: 12),
            InlineBanner(
              icon: Icons.warning_amber_rounded,
              title: '${alerts.lowStockCount} low:',
              message: '$names$more',
              actionLabel: 'Buy list',
              onTap: () => _open(RouteNames.buyList),
            ),
          ],
          const SizedBox(height: 16),
          StatusFilterChips(
            selected: _statusFilter,
            counts: counts,
            onChanged: (s) => setState(() => _statusFilter = s),
          ),
          if (due.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionLabel('Ships today · ${due.length}'),
            const SizedBox(height: 8),
            ..._cards(due),
          ],
          if (placed.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionLabel('New today · ${placed.length}'),
            const SizedBox(height: 8),
            ..._cards(placed),
          ],
          if (due.isEmpty && placed.isEmpty)
            EmptyState(
              icon: Icons.local_florist_outlined,
              title: d.due.isEmpty && d.placedToday.isEmpty
                  ? 'All clear for today'
                  : 'Nothing matches this filter',
              message: d.due.isEmpty && d.placedToday.isEmpty
                  ? 'Orders shipping today and new orders show up here.'
                  : 'Pick another status or tap All.',
            ),
        ],
      ),
    );
  }

  List<Widget> _cards(List<OrderListEntry> entries) => [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BlocBuilder<OrderAmountCubit, OrderAmountShown>(
              bloc: getIt(),
              builder: (context, shown) => OrderCard(
                entry: e,
                amountShown: shown,
                onTap: () => _open(RouteNames.orderPath(e.order.id!)),
              ),
            ),
          ),
      ];
}
