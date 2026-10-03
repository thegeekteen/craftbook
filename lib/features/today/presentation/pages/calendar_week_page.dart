import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/status_filter_chips.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/usecases/get_week_orders.dart';

/// Calendar week view — shows orders grouped by day for the current week.
class CalendarWeekPage extends StatefulWidget {
  const CalendarWeekPage({super.key});

  @override
  State<CalendarWeekPage> createState() => _CalendarWeekPageState();
}

class _CalendarWeekPageState extends State<CalendarWeekPage> {
  late final GetWeekOrders _getWeekOrders;
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  Set<OrderStatus> _statusFilter = Set.from(OrderStatus.values);
  final DateTime _weekStart = app_date.DateUtils.startOfWeek(DateTime.now());

  @override
  void initState() {
    super.initState();
    _getWeekOrders = getIt<GetWeekOrders>();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _getWeekOrders();
    if (!mounted) return;

    switch (result) {
      case Error(:final failure):
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      case Success(:final value):
        setState(() {
          _orders = value;
          _isLoading = false;
        });
    }
  }

  /// Returns orders whose shipByDate falls on the given day, filtered by status.
  List<Order> _ordersForDay(DateTime day) {
    return _orders.where((o) {
      if (!_statusFilter.contains(o.status)) return false;
      final shipDay = DateTime(o.shipByDate.year, o.shipByDate.month, o.shipByDate.day);
      final target = DateTime(day.year, day.month, day.day);
      return shipDay.isAtSameMomentAs(target);
    }).toList();
  }

  String _weekTitle() {
    final end = _weekStart.add(const Duration(days: 6));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final startMonth = months[_weekStart.month - 1];
    final endMonth = months[end.month - 1];
    if (_weekStart.month == end.month) {
      return '$startMonth ${_weekStart.day} – ${end.day}';
    }
    return '$startMonth ${_weekStart.day} – $endMonth ${end.day}';
  }

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _weekTitle(),
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_month_outlined, size: 20),
            tooltip: 'Month view',
            onPressed: () => context.pushReplacement(RouteNames.calendarMonth),
          ),
        ],
      ),
      body: _buildBody(dayLabels, today),
    );
  }

  Widget _buildBody(List<String> dayLabels, DateTime today) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.alert, size: 40),
            const SizedBox(height: 8),
            Text(_error!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        StatusFilterChips(
          selected: _statusFilter,
          onChanged: (s) => setState(() => _statusFilter = s),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 7,
        itemBuilder: (context, index) {
          final day = _weekStart.add(Duration(days: index));
          final dayOrders = _ordersForDay(day);
          final isToday = app_date.DateUtils.isSameDay(day, today);
          final dayLabel = dayLabels[index];

          return _DaySection(
            dayLabel: dayLabel,
            date: day,
            isToday: isToday,
            orders: dayOrders,
          );
        },
            ),
          ),
        ),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  final String dayLabel;
  final DateTime date;
  final bool isToday;
  final List<Order> orders;

  const _DaySection({
    required this.dayLabel,
    required this.date,
    required this.isToday,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isToday ? AppColors.successSoft : AppColors.paper,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayLabel.toUpperCase(),
                  style: AppTextStyles.monoSection.copyWith(
                    color: isToday ? AppColors.success : AppColors.muted,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${date.day}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isToday ? AppColors.success : AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Orders for this day
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                'No orders',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
              ),
            )
          else
            ...orders.map((order) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _WeekOrderRow(order: order),
            )),
        ],
      ),
    );
  }
}

class _WeekOrderRow extends StatelessWidget {
  final Order order;

  const _WeekOrderRow({required this.order});

  StatusPillType get _statusPillType {
    switch (order.status) {
      case OrderStatus.pending:
        return StatusPillType.warning;
      case OrderStatus.packed:
        return StatusPillType.success;
      case OrderStatus.shipped:
        return StatusPillType.coin;
      case OrderStatus.cancelled:
        return StatusPillType.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        RouteNames.orderDetail.replaceFirst(':id', '${order.id}'),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.paperHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.hair),
        ),
        child: Row(
          children: [
            // Customer name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${order.id ?? '?'}',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),

            // Ship-by date
            Icon(
              Icons.local_shipping_outlined,
              size: 13,
              color: AppColors.muted,
            ),
            const SizedBox(width: 3),
            Text(
              app_date.DateUtils.getRelativeDate(order.shipByDate),
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(width: 8),

            // Status pill
            StatusPill(
              text: order.status.displayName,
              type: _statusPillType,
            ),
          ],
        ),
      ),
    );
  }
}
