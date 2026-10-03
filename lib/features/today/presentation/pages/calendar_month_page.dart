import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/status_filter_chips.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/repositories/order_repository.dart';

/// Calendar month view — shows a standard calendar grid with order indicators.
/// Tapping a day reveals orders for that day in a bottom section.
class CalendarMonthPage extends StatefulWidget {
  const CalendarMonthPage({super.key});

  @override
  State<CalendarMonthPage> createState() => _CalendarMonthPageState();
}

class _CalendarMonthPageState extends State<CalendarMonthPage> {
  late final OrderRepository _orderRepository;
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  DateTime _selectedDay = DateTime.now();
  late DateTime _displayMonth;
  Set<OrderStatus> _statusFilter = Set.from(OrderStatus.values);

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _orderRepository = getIt<OrderRepository>();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final start = app_date.DateUtils.startOfMonth(_displayMonth);
    final end = app_date.DateUtils.endOfMonth(_displayMonth);

    final result = await _orderRepository.getOrdersForDateRange(start, end);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (orders) => setState(() {
        _orders = orders;
        _isLoading = false;
      }),
    );
  }

  void _previousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
    _loadOrders();
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
    _loadOrders();
  }

  /// Returns orders whose shipByDate falls on the given day, filtered by status.
  List<Order> _ordersForDay(DateTime day) {
    return _orders.where((o) {
      if (!_statusFilter.contains(o.status)) return false;
      return app_date.DateUtils.isSameDay(o.shipByDate, day);
    }).toList();
  }

  /// Check if a day has any orders (respecting status filter).
  bool _hasOrders(DateTime day) {
    return _orders.any((o) =>
        _statusFilter.contains(o.status) &&
        app_date.DateUtils.isSameDay(o.shipByDate, day));
  }

  /// Build the grid of days for the current month.
  List<DateTime> _buildCalendarDays() {
    final firstOfMonth = DateTime(_displayMonth.year, _displayMonth.month, 1);
    // weekday: 1=Mon, 7=Sun; we start the grid on Monday
    final startOffset = firstOfMonth.weekday - DateTime.monday;
    final gridStart = firstOfMonth.subtract(Duration(days: startOffset));

    // Always show 6 weeks (42 days) to cover all months
    return List.generate(42, (i) => gridStart.add(Duration(days: i)));
  }

  List<Order> get _selectedDayOrders => _ordersForDay(_selectedDay);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_week_outlined, size: 20),
            tooltip: 'Week view',
            onPressed: () => context.pushReplacement(RouteNames.calendarWeek),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
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

  Widget _buildContent() {
    final days = _buildCalendarDays();
    final today = DateTime.now();

    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              Text(
                '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
        ),

        // Status filter chips
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: StatusFilterChips(
            selected: _statusFilter,
            onChanged: (s) => setState(() => _statusFilter = s),
          ),
        ),

        // Day-of-week headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d.toUpperCase(),
                          style: AppTextStyles.monoSection,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),

        // Calendar grid
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isCurrentMonth = day.month == _displayMonth.month;
                final isToday = app_date.DateUtils.isSameDay(day, today);
                final isSelected = app_date.DateUtils.isSameDay(day, _selectedDay);
                final hasOrders = isCurrentMonth && _hasOrders(day);

                return GestureDetector(
                  onTap: isCurrentMonth
                      ? () => setState(() => _selectedDay = day)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.successSoft
                          : isToday
                              ? AppColors.paper
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.success, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isCurrentMonth
                                ? (isToday ? AppColors.success : AppColors.ink)
                                : AppColors.hair,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Order indicator dot
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasOrders ? AppColors.warning : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Selected day orders section
        Expanded(
          flex: 2,
          child: _buildSelectedDayOrders(),
        ),
      ],
    );
  }

  Widget _buildSelectedDayOrders() {
    final dayOrders = _selectedDayOrders;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.hair)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '${months[_selectedDay.month - 1]} ${_selectedDay.day} orders'
                  .toUpperCase(),
              style: AppTextStyles.monoSection,
            ),
          ),
          if (dayOrders.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No orders for this day',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dayOrders.length,
                itemBuilder: (context, index) {
                  final order = dayOrders[index];
                  return _MonthOrderRow(order: order);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthOrderRow extends StatelessWidget {
  final Order order;

  const _MonthOrderRow({required this.order});

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
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.paperHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.hair),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                order.customerName,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.ink,
                ),
              ),
            ),
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
