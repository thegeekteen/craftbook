import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/status_filter_chips.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_list_entry.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../orders/domain/usecases/get_order_list_entries.dart';
import '../../../orders/presentation/widgets/order_mini_row.dart';
import '../../../orders/presentation/widgets/order_status_ui.dart';
import '../../../settings/domain/entities/order_amount_shown.dart';
import '../../../settings/presentation/bloc/order_amount_cubit.dart';

enum CalendarMode { week, month }

/// Orders by ship-by date, as a week list or a month grid.
class CalendarPage extends StatefulWidget {
  final CalendarMode initialMode;

  const CalendarPage({super.key, this.initialMode = CalendarMode.week});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _orderRepository = getIt<OrderRepository>();
  final _getEntries = getIt<GetOrderListEntries>();

  late CalendarMode _mode = widget.initialMode;
  late DateTime _anchor = app_date.DateUtils.startOfDay(DateTime.now());
  late DateTime _selectedDay = _anchor;
  Set<OrderStatus> _statusFilter = Set.from(OrderStatus.values);

  List<OrderListEntry> _entries = [];
  bool _loading = true;
  String? _error;

  /// Set when an order was changed from here, so Today reloads on return.
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  (DateTime, DateTime) get _range {
    if (_mode == CalendarMode.week) {
      final start = app_date.DateUtils.startOfWeek(_anchor);
      return (start, start.add(const Duration(days: 7)));
    }
    final days = _monthGrid();
    return (days.first, days.last.add(const Duration(days: 1)));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final (start, end) = _range;
    final result = await _orderRepository.getOrdersForDateRange(start, end);
    if (!mounted) return;
    switch (result) {
      case Error(:final failure):
        setState(() {
          _error = failure.message;
          _loading = false;
        });
        return;
      case Success(:final value):
        final entries = await _getEntries(value);
        if (!mounted) return;
        setState(() {
          switch (entries) {
            case Error(:final failure):
              _error = failure.message;
            case Success(:final value):
              _entries = value;
          }
          _loading = false;
        });
    }
  }

  void _shift(int direction) {
    setState(() {
      _anchor = _mode == CalendarMode.week
          ? _anchor.add(Duration(days: 7 * direction))
          : DateTime(_anchor.year, _anchor.month + direction, 1);
      if (_mode == CalendarMode.month) _selectedDay = _anchor;
    });
    _load();
  }

  void _setMode(CalendarMode mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _anchor = _selectedDay;
    });
    _load();
  }

  List<OrderListEntry> _forDay(DateTime day) => _entries
      .where((e) =>
          _statusFilter.contains(e.order.status) &&
          app_date.DateUtils.isSameDay(e.order.shipByDate, day))
      .toList();

  List<DateTime> _monthGrid() {
    final first = DateTime(_anchor.year, _anchor.month, 1);
    final start = first.subtract(Duration(days: first.weekday - DateTime.monday));
    final last = DateTime(_anchor.year, _anchor.month + 1, 0);
    final weeks = ((last.difference(start).inDays + 1) / 7).ceil();
    return List.generate(weeks * 7, (i) => DateTime(start.year, start.month, start.day + i));
  }

  String get _title {
    if (_mode == CalendarMode.month) {
      return DateFormat(_anchor.year == DateTime.now().year ? 'MMMM' : 'MMMM y')
          .format(_anchor);
    }
    final start = app_date.DateUtils.startOfWeek(_anchor);
    final end = start.add(const Duration(days: 6));
    final startText = DateFormat('MMM d').format(start);
    final endText = DateFormat(start.month == end.month ? 'd' : 'MMM d').format(end);
    return '$startText – $endText';
  }

  Future<void> _openOrder(Order order) async {
    final changed = await context.push<bool>(RouteNames.orderPath(order.id!));
    if (changed == true && mounted) {
      _changed = true;
      _load();
    }
  }

  Widget _miniRow(OrderListEntry e) =>
      BlocBuilder<OrderAmountCubit, OrderAmountShown>(
        bloc: getIt(),
        builder: (context, shown) => OrderMiniRow(
          entry: e,
          amountShown: shown,
          onTap: () => _openOrder(e.order),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop(_changed)),
          title: Text(_title),
          actions: [
            IconButton(
              tooltip: _mode == CalendarMode.week ? 'Previous week' : 'Previous month',
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => _shift(-1),
            ),
            IconButton(
              tooltip: _mode == CalendarMode.week ? 'Next week' : 'Next month',
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => _shift(1),
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<CalendarMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: CalendarMode.week, label: Text('Week')),
                    ButtonSegment(value: CalendarMode.month, label: Text('Month')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => _setMode(s.first),
                ),
              ),
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: ErrorState(message: _error!, onRetry: _load));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: AppSpacing.page.copyWith(top: 8),
        children: [
          StatusFilterChips(
            selected: _statusFilter,
            onChanged: (s) => setState(() => _statusFilter = s),
          ),
          const SizedBox(height: 16),
          if (_mode == CalendarMode.week) ..._buildWeek() else ..._buildMonth(),
        ],
      ),
    );
  }

  List<Widget> _buildWeek() {
    final start = app_date.DateUtils.startOfWeek(_anchor);
    final c = context.colors;
    return [
      for (var i = 0; i < 7; i++)
        Builder(builder: (context) {
          final day = DateTime(start.year, start.month, start.day + i);
          final orders = _forDay(day);
          final isToday = app_date.DateUtils.isToday(day);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DayBadge(day: day, highlighted: isToday),
                const SizedBox(width: 10),
                Expanded(
                  child: orders.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            'Nothing due',
                            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                          ),
                        )
                      : Column(
                          children: [
                            for (final e in orders)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: _miniRow(e),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          );
        }),
    ];
  }

  List<Widget> _buildMonth() {
    final c = context.colors;
    final days = _monthGrid();
    final selected = _forDay(_selectedDay);
    const dow = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return [
      Row(
        children: [
          for (final d in dow)
            Expanded(
              child: Center(
                child: Text(d, style: AppTextStyles.monoTag.copyWith(color: c.muted)),
              ),
            ),
        ],
      ),
      const SizedBox(height: 6),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: [
          for (final day in days)
            _MonthCell(
              day: day,
              inMonth: day.month == _anchor.month,
              isToday: app_date.DateUtils.isToday(day),
              isSelected: app_date.DateUtils.isSameDay(day, _selectedDay),
              dots: [
                for (final e in _forDay(day).take(3))
                  orderStatusColor(e.order,
                      alert: c.alert, warn: c.warn, go: c.go, coin: c.coin, muted: c.muted),
              ],
              onTap: () => setState(() => _selectedDay = day),
            ),
        ],
      ),
      const SizedBox(height: 12),
      SectionLabel(
        '${DateFormat('EEE, MMM d').format(_selectedDay)} · '
        '${selected.length} ${selected.length == 1 ? 'order' : 'orders'}',
      ),
      const SizedBox(height: 8),
      if (selected.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Nothing ships this day.',
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
        )
      else
        for (final e in selected)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _miniRow(e),
          ),
    ];
  }
}

class _DayBadge extends StatelessWidget {
  final DateTime day;
  final bool highlighted;

  const _DayBadge({required this.day, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = highlighted ? c.onAccent : c.ink;
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: highlighted ? c.go : c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlighted ? c.go : c.hair),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('EEE').format(day).toUpperCase(),
            style: AppTextStyles.monoTag.copyWith(color: highlighted ? fg : c.muted),
          ),
          Text(
            '${day.day}',
            style: AppTextStyles.amount.copyWith(color: fg, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _MonthCell extends StatelessWidget {
  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final List<Color> dots;
  final VoidCallback onTap;

  const _MonthCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.dots,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = isSelected ? c.ink : (isToday ? c.goSoft : Colors.transparent);
    final fg = isSelected
        ? c.paper
        : isToday
            ? c.go
            : inMonth
                ? c.ink
                : c.hair;
    return Material(
      color: bg,
      borderRadius: AppRadii.controlAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: fg,
                fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                fontFeatures: AppTextStyles.tabular.fontFeatures,
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final color in dots)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? c.paper : color,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
