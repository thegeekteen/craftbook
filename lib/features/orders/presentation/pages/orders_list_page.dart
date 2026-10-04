import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../settings/domain/entities/order_amount_shown.dart';
import '../../../settings/presentation/bloc/order_amount_cubit.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_list_entry.dart';
import '../bloc/orders_list_bloc.dart';
import '../bloc/orders_list_event.dart';
import '../bloc/orders_list_state.dart';
import '../widgets/order_actions.dart';
import '../widgets/order_card.dart';
import '../widgets/order_status_ui.dart';

/// Every order, filtered by status chips and search.
class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrdersListBloc>()..add(const LoadOrders()),
      child: const _OrdersListView(),
    );
  }
}

class _OrdersListView extends StatefulWidget {
  const _OrdersListView();

  @override
  State<_OrdersListView> createState() => _OrdersListViewState();
}

class _OrdersListViewState extends State<_OrdersListView> {
  /// null means "All".
  OrderStatus? _status = OrderStatus.pending;
  String _query = '';

  void _reload() => context.read<OrdersListBloc>().add(const LoadOrders());

  Future<void> _open(String location) async {
    final changed = await context.push<bool>(location);
    if (changed == true && mounted) _reload();
  }

  bool _matches(OrderListEntry e) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase().replaceFirst('#', '');
    return e.order.customerName.toLowerCase().contains(q) ||
        '${e.order.id}' == q ||
        (e.channelName?.toLowerCase().contains(q) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: BlocBuilder<OrdersListBloc, OrdersListState>(
        builder: (context, state) {
          return switch (state) {
            OrdersListLoaded(:final entries) => _buildLoaded(entries),
            OrdersListError(:final message) =>
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

  Widget _buildLoaded(List<OrderListEntry> all) {
    final searched = all.where(_matches).toList();
    int count(OrderStatus s) =>
        searched.where((e) => e.order.status == s).length;
    // "All" means everything still in play; cancelled orders only show
    // under their own chip.
    final active =
        searched.where((e) => e.order.status != OrderStatus.cancelled).toList();
    final visible = _status == null
        ? active
        : searched.where((e) => e.order.status == _status).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: AppSearchField(
            hint: 'Search name, # or channel',
            onChanged: (v) => setState(() => _query = v.trim()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ChoiceChipRow<OrderStatus?>.single(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            selected: _status,
            onSelected: (s) => setState(() => _status = s),
            options: [
              ChipOption(null, 'All', count: active.length),
              for (final s in OrderStatus.values)
                ChipOption(s, s.label, count: count(s)),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              final done = Completer<void>();
              context.read<OrdersListBloc>().add(LoadOrders(done: done));
              return done.future;
            },
            child: visible.isEmpty
                ? ListView(children: [_empty(all.isEmpty)])
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                        16, 4, 16, AppSpacing.fabClearance),
                    children: [
                      for (final group in _group(visible)) ...[
                        SectionLabel(
                            '${group.title} · ${group.entries.length}'),
                        const SizedBox(height: 8),
                        for (final e in group.entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child:
                                BlocBuilder<OrderAmountCubit, OrderAmountShown>(
                              bloc: getIt(),
                              builder: (context, shown) => OrderCard(
                                entry: e,
                                amountShown: shown,
                                onTap: () =>
                                    _open(RouteNames.orderPath(e.order.id!)),
                                onLongPress: () async {
                                  if (await OrderActions.open(
                                          context, e.order) &&
                                      mounted) {
                                    _reload();
                                  }
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _empty(bool noOrdersAtAll) {
    if (noOrdersAtAll) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No orders yet',
        message: 'Your first order will show up here.',
        actionLabel: 'New order',
        onAction: () => _open(RouteNames.newOrder),
      );
    }
    if (_query.isNotEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matches',
        message: 'Nothing matches "$_query".',
      );
    }
    final label = _status?.label.toLowerCase() ?? '';
    return EmptyState(
      icon: Icons.check_circle_outline_rounded,
      title: _status == OrderStatus.pending
          ? 'Nothing to pack'
          : 'No $label orders',
      message: _status == OrderStatus.pending
          ? 'Every order is packed. Nice work.'
          : null,
    );
  }

  /// Groups that make the list scannable: urgency for open orders, month
  /// for finished ones.
  List<_Group> _group(List<OrderListEntry> entries) {
    final today = app_date.DateUtils.startOfDay(DateTime.now());
    final weekEnd = today.add(const Duration(days: 7));
    final groups = <String, List<OrderListEntry>>{};
    void add(String key, OrderListEntry e) =>
        groups.putIfAbsent(key, () => []).add(e);

    final open = entries
        .where((e) =>
            e.order.status == OrderStatus.pending ||
            e.order.status == OrderStatus.packed)
        .toList()
      ..sort((a, b) => a.order.shipByDate.compareTo(b.order.shipByDate));
    for (final e in open) {
      final due = app_date.DateUtils.startOfDay(e.order.shipByDate);
      if (e.order.status == OrderStatus.packed) {
        add('Packed, ready to ship', e);
      } else if (due.isBefore(today)) {
        add('Overdue', e);
      } else if (due.isBefore(weekEnd)) {
        add('Due this week', e);
      } else {
        add('Later', e);
      }
    }

    final closed = entries
        .where((e) =>
            e.order.status == OrderStatus.shipped ||
            e.order.status == OrderStatus.cancelled)
        .toList()
      ..sort((a, b) => _closedAt(b.order).compareTo(_closedAt(a.order)));
    for (final e in closed) {
      add(DateFormat('MMMM y').format(_closedAt(e.order)), e);
    }

    return [for (final g in groups.entries) _Group(g.key, g.value)];
  }

  DateTime _closedAt(Order o) => o.shippedAt ?? o.updatedAt;
}

class _Group {
  final String title;
  final List<OrderListEntry> entries;

  const _Group(this.title, this.entries);
}
