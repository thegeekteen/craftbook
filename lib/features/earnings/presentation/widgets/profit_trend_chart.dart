import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/profit_trend.dart';

/// Profit bars for the dark summary board. Today's (or this month's) bar is
/// fully lit; losses drop below the baseline in red.
class ProfitTrendChart extends StatelessWidget {
  final List<TrendBucket> buckets;
  final TrendGranularity granularity;
  final double height;

  const ProfitTrendChart({
    super.key,
    required this.buckets,
    required this.granularity,
    this.height = 110,
  });

  bool _isCurrent(DateTime d) {
    final now = DateTime.now();
    return granularity == TrendGranularity.day
        ? d.year == now.year && d.month == now.month && d.day == now.day
        : d.year == now.year && d.month == now.month;
  }

  String _label(int i) {
    final d = buckets[i].start;
    if (granularity == TrendGranularity.month) {
      return DateFormat('MMMMM').format(d);
    }
    if (buckets.length <= 7) return DateFormat('EEEEE').format(d);
    // A month of days: label the 1st and every 7th day to avoid crowding.
    return (d.day == 1 || d.day % 7 == 0) ? '${d.day}' : '';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // The board is dark in both themes, so use the dark palette's green.
    final onBoard = CraftColors.dark.go;
    if (buckets.isEmpty) return SizedBox(height: height);
    final maxY = buckets.map((b) => b.profit).fold<double>(0, math.max);
    final minY = buckets.map((b) => b.profit).fold<double>(0, math.min);
    final top = maxY <= 0 ? 1.0 : maxY * 1.1;
    final bottom = minY < 0 ? minY * 1.1 : 0.0;
    final barWidth =
        buckets.length > 14 ? 5.0 : (buckets.length > 7 ? 12.0 : 18.0);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: top,
          minY: bottom,
          alignment: BarChartAlignment.spaceBetween,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border(bottom: BorderSide(color: c.boardRaised)),
          ),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= buckets.length) {
                    return const SizedBox.shrink();
                  }
                  final current = _isCurrent(buckets[i].start);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(
                      _label(i),
                      style: AppTextStyles.monoTag.copyWith(
                        color: current ? c.boardInk : c.boardMuted,
                        fontSize: 9.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => c.surface,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, _, rod, __) {
                final b = buckets[group.x];
                final when = granularity == TrendGranularity.day
                    ? DateFormat('EEE, MMM d').format(b.start)
                    : DateFormat('MMMM').format(b.start);
                return BarTooltipItem(
                  '$when\n',
                  AppTextStyles.bodySmall
                      .copyWith(color: c.muted, fontSize: 11),
                  children: [
                    TextSpan(
                      text: CurrencyFormatter.formatShort(b.profit),
                      style: AppTextStyles.amount.copyWith(
                        color: b.profit < 0 ? c.alert : c.ink,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < buckets.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: buckets[i].profit,
                    width: barWidth,
                    color: buckets[i].profit < 0
                        ? CraftColors.dark.alert
                        : (_isCurrent(buckets[i].start)
                            ? onBoard
                            : onBoard.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(buckets[i].profit >= 0 ? 3 : 0),
                      bottom: Radius.circular(buckets[i].profit < 0 ? 3 : 0),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: top,
                      fromY: 0,
                      color: c.boardRaised.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
          ],
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }
}
