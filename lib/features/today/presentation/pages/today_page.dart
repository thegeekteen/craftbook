import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/usecases/get_alert_summary.dart';
import '../bloc/today_bloc.dart';
import '../bloc/today_event.dart';
import '../bloc/today_state.dart';
import '../widgets/order_card.dart';

/// Today page — main dashboard (Flow 1)
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TodayBloc>()..add(LoadToday())..add(LoadAlerts()),
      child: const _TodayView(),
    );
  }
}

class _TodayView extends StatelessWidget {
  const _TodayView();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = now
        .toString()
        .substring(0, 10); // fallback; use DateUtils in real display

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatHeader(now),
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<TodayBloc, TodayState>(
        listener: (context, state) {
          if (state is TodayError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is TodayLoading || state is TodayInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TodayError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: AppColors.alert, size: 40),
                  const SizedBox(height: 8),
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TodayBloc>()
                        ..add(LoadToday())
                        ..add(LoadAlerts()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TodayLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TodayBloc>()
                  ..add(LoadToday())
                  ..add(LoadAlerts());
              },
              child: Builder(
                builder: (context) {
                  final today = DateTime.now();
                  final todayDate = DateTime(today.year, today.month, today.day);
                  final shipTodayOrders = state.orders.where((o) =>
                    o.status == OrderStatus.pending &&
                    o.shipByDate.year == todayDate.year &&
                    o.shipByDate.month == todayDate.month &&
                    o.shipByDate.day == todayDate.day).toList();
                  final newTodayOrders = state.orders.where((o) =>
                    o.orderDate.year == todayDate.year &&
                    o.orderDate.month == todayDate.month &&
                    o.orderDate.day == todayDate.day).toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary header
                      _SummaryHeader(
                        packCount: shipTodayOrders.length,
                        newCount: newTodayOrders.length,
                      ),
                      const SizedBox(height: 12),

                      // Alert banner
                      if (state.alertSummary.hasAlerts) ...[
                        _AlertBanner(
                          lowStockCount: state.alertSummary.lowStockCount,
                          materialNames: state.alertSummary.materialNames,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Ships today section
                      if (shipTodayOrders.isNotEmpty) ...[
                        _SectionHeader(title: 'Ships today'),
                        const SizedBox(height: 8),
                        ...shipTodayOrders.map(
                          (order) => OrderCard(order: order),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // New today section
                      if (newTodayOrders.isNotEmpty) ...[
                        _SectionHeader(title: 'New today'),
                        const SizedBox(height: 8),
                        ...newTodayOrders.map(
                          (order) => OrderCard(order: order),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Empty state
                      if (shipTodayOrders.isEmpty &&
                          newTodayOrders.isEmpty)
                        _EmptyState(),
                    ],
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.newOrder),
        backgroundColor: AppColors.success,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatHeader(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}';
  }
}

class _SummaryHeader extends StatelessWidget {
  final int packCount;
  final int newCount;

  const _SummaryHeader({required this.packCount, required this.newCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paperHigh,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.hair),
      ),
      child: Row(
        children: [
          _SummaryItem(
            count: packCount,
            label: 'to pack',
            color: AppColors.warning,
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.hair,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _SummaryItem(
            count: newCount,
            label: 'new today',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: AppTextStyles.displayMedium.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.monoSection,
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final int lowStockCount;
  final List<String> materialNames;

  const _AlertBanner({
    required this.lowStockCount,
    required this.materialNames,
  });

  @override
  Widget build(BuildContext context) {
    final names = materialNames.take(3).join(', ');
    final extra = materialNames.length > 3
        ? ' +${materialNames.length - 3} more'
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.alertSoft,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.alert.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.alert, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$lowStockCount low stock: $names$extra',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.alert,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.monoSection,
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.muted, size: 48),
          const SizedBox(height: 12),
          Text(
            'No orders today',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to create a new order',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
