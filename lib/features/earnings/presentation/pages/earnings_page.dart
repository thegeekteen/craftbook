import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/currency_text.dart';
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

  static const _rangeLabels = ['Week', 'Month', 'Year'];

  void _onRangeChanged(int index) {
    setState(() => _selectedRange = index);

    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (index) {
      case 0: // Week
        start = app_date.DateUtils.startOfWeek(now);
        end = app_date.DateUtils.endOfWeek(now);
        break;
      case 1: // Month
        start = app_date.DateUtils.startOfMonth(now);
        end = app_date.DateUtils.endOfMonth(now);
        break;
      case 2: // Year
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      default:
        start = app_date.DateUtils.startOfWeek(now);
        end = app_date.DateUtils.endOfWeek(now);
    }

    context.read<EarningsBloc>().add(LoadEarnings(
          startDate: start,
          endDate: end,
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
              // Range selector
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _RangeSelector(
                  selectedIndex: _selectedRange,
                  onSelected: _onRangeChanged,
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
        onRefresh: () async {
          // Re-trigger load with current range
          _onRangeChanged(_selectedRange);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary card
            EarningsSummaryCard(summary: state.summary),
            const SizedBox(height: 24),

            // Product earnings
            if (state.productEarnings.isNotEmpty) ...[
              Text('BY PRODUCT', style: AppTextStyles.monoSection),
              const SizedBox(height: 8),
              ...state.productEarnings.map(
                (pe) => ProductProfitCard(earnings: pe),
              ),
              const SizedBox(height: 24),
            ],

            // Waste summary
            if (state.wasteSummary.totalWasteQuantity > 0) ...[
              Text('WASTE', style: AppTextStyles.monoSection),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.alertSoft.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(13),
                  border:
                      Border.all(color: AppColors.alert.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${state.wasteSummary.totalWasteQuantity} pcs wasted',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.alert),
                          ),
                          Text(
                            'Total waste cost',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    CurrencyText(
                      amount: state.wasteSummary.totalWasteCost,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.alert),
                    ),
                  ],
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.paperHigh : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: AppColors.hair)
                      : null,
                ),
                child: Center(
                  child: Text(
                    _EarningsViewState._rangeLabels[index].toUpperCase(),
                    style: AppTextStyles.monoLabel.copyWith(
                      color: isSelected ? AppColors.ink : AppColors.muted,
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
}
