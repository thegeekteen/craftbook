import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/section_card.dart';
import '../bloc/earnings_bloc.dart';
import '../bloc/earnings_event.dart';
import '../bloc/earnings_state.dart';
import '../widgets/earnings_summary_card.dart';
import '../widgets/product_profit_card.dart';

/// Earnings page — Flow 6: Earnings overview
class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final now = DateTime.now();
        final start = app_date.DateUtils.startOfWeek(now);
        final end = app_date.DateUtils.endOfWeek(now);
        return getIt<EarningsBloc>()
          ..add(LoadEarnings(startDate: start, endDate: end));
      },
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
  int _selectedRange = 0; // 0=Week, 1=Month, 2=Year
  int _offset = 0; // period offset: 0=current, -1=previous, +1=next, etc.

  static const _rangeLabels = ['Week', 'Month', 'Year'];

  DateTimeRange get _currentRange {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (_selectedRange) {
      case 0: // Week
        final baseStart = app_date.DateUtils.startOfWeek(now);
        start = baseStart.add(Duration(days: 7 * _offset));
        end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case 1: // Month
        final baseMonth = DateTime(now.year, now.month + _offset, 1);
        start = baseMonth;
        end = DateTime(baseMonth.year, baseMonth.month + 1, 0, 23, 59, 59);
        break;
      case 2: // Year
        final year = now.year + _offset;
        start = DateTime(year, 1, 1);
        end = DateTime(year, 12, 31, 23, 59, 59);
        break;
      default:
        start = app_date.DateUtils.startOfWeek(now);
        end = app_date.DateUtils.endOfWeek(now);
    }

    return DateTimeRange(start: start, end: end);
  }

  String get _rangeLabel {
    final range = _currentRange;
    switch (_selectedRange) {
      case 0: // Week
        final fmt = DateFormat('MMM d');
        return '${fmt.format(range.start)} – ${fmt.format(range.end)}';
      case 1: // Month
        return DateFormat('MMMM y').format(range.start);
      case 2: // Year
        return DateFormat('y').format(range.start);
      default:
        return '';
    }
  }

  void _onRangeChanged(int index) {
    setState(() {
      _selectedRange = index;
      _offset = 0;
    });
    _reload();
  }

  void _onPrevious() {
    setState(() => _offset--);
    _reload();
  }

  void _onNext() {
    if (_offset < 0) {
      setState(() => _offset++);
      _reload();
    }
  }

  bool get _canGoNext => _offset < 0;

  void _reload() {
    final range = _currentRange;
    context.read<EarningsBloc>().add(LoadEarnings(
          startDate: range.start,
          endDate: range.end,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings',
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        ),
      ),
      body: BlocConsumer<EarningsBloc, EarningsState>(
        listener: (context, state) {
          if (state is EarningsError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Range type selector
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _RangeSelector(
                  selectedIndex: _selectedRange,
                  onSelected: _onRangeChanged,
                ),
              ),
              const SizedBox(height: 12),

              // Period navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _onPrevious,
                      icon: const Icon(Icons.chevron_left, size: 22),
                      color: AppColors.ink,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _rangeLabel,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _canGoNext ? _onNext : null,
                      icon: const Icon(Icons.chevron_right, size: 22),
                      color: _canGoNext ? AppColors.ink : AppColors.muted,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, EarningsState state) {
    if (state is EarningsLoading || state is EarningsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is EarningsLoaded) {
      return RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary card
            EarningsSummaryCard(summary: state.summary),
            const SizedBox(height: 20),

            // Product earnings
            if (state.productEarnings.isNotEmpty) ...[
              SectionCard(
                label: 'By Product',
                padding: EdgeInsets.zero,
                child: Column(
                  children: state.productEarnings
                      .map((pe) => ProductProfitCard(earnings: pe))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Waste summary
            if (state.wasteSummary.totalWasteQuantity > 0) ...[
              SectionCard(
                label: 'Waste',
                padding: EdgeInsets.zero,
                child: Column(
                  children: state.wasteSummary.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.materialName,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.ink),
                                ),
                                Text(
                                  '${item.quantity} pcs wasted',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          CurrencyText(
                            amount: item.cost,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.alert,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (state is EarningsError) {
      return Center(
        child: Text(state.message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.alert)),
      );
    }

    return const SizedBox.shrink();
  }
}

class _RangeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _RangeSelector({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _rangeLabels[index].toUpperCase(),
                    style: AppTextStyles.monoLabel.copyWith(
                      color: isSelected ? Colors.white : AppColors.muted,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  static const _rangeLabels = ['Week', 'Month', 'Year'];
}
