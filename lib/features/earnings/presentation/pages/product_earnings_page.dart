import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../domain/entities/product_earnings.dart';
import '../../domain/usecases/get_product_earnings.dart';

/// Per-product earnings drill-down page
class ProductEarningsPage extends StatefulWidget {
  final int productId;

  const ProductEarningsPage({super.key, required this.productId});

  @override
  State<ProductEarningsPage> createState() => _ProductEarningsPageState();
}

class _ProductEarningsPageState extends State<ProductEarningsPage> {
  ProductEarnings? _earnings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final getProductEarnings = getIt<GetProductEarnings>();
    final result = await getProductEarnings(start, end);

    switch (result) {
      case Error(:final failure):
        if (mounted) {
          setState(() => _isLoading = false);
          context.showSnackBar(failure.message, isError: true);
        }
      case Success(:final value):
        final earnings = value
            .where((p) => p.productId == widget.productId)
            .firstOrNull;

        if (mounted) {
          setState(() {
            _earnings = earnings;
            _isLoading = false;
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product earnings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_earnings == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product earnings')),
        body: const Center(child: Text('No earnings data for this product')),
      );
    }

    final e = _earnings!;

    return Scaffold(
      appBar: AppBar(
        title: Text(e.productName,
            style:
                AppTextStyles.displaySmall.copyWith(color: AppColors.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.coinSoft.withOpacity(0.3),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.coin.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PROFIT',
                    style: AppTextStyles.monoSection
                        .copyWith(color: AppColors.coin)),
                const SizedBox(height: 4),
                CurrencyText(
                  amount: e.totalProfit,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: e.totalProfit >= 0
                        ? AppColors.coin
                        : AppColors.alert,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.hair),
                const SizedBox(height: 8),
                _Row(
                    label: 'Quantity sold',
                    value: '${e.quantitySold}'),
                const SizedBox(height: 6),
                _Row(
                    label: 'Total sales',
                    value: e.totalSales.currency),
                const SizedBox(height: 6),
                _Row(
                    label: 'Total profit',
                    value: e.totalProfit.currency),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink)),
      ],
    );
  }
}
