import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../domain/entities/profit_trend.dart';
import '../../domain/entities/report_filter.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/usecases/get_product_order_lines.dart';

/// What one product earned in a period, and the orders behind it.
class ProductEarningsPage extends StatefulWidget {
  final int productId;
  final DateTime? startDate;
  final DateTime? endDate;

  const ProductEarningsPage({
    super.key,
    required this.productId,
    this.startDate,
    this.endDate,
    this.filter = ReportFilter.none,
  });

  /// The report's filter, so the orders listed match its numbers.
  final ReportFilter filter;

  @override
  State<ProductEarningsPage> createState() => _ProductEarningsPageState();
}

class _ProductEarningsPageState extends State<ProductEarningsPage> {
  late final DateTime _start =
      widget.startDate ?? DateTime(DateTime.now().year, DateTime.now().month);
  late final DateTime _end = widget.endDate ??
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0, 23, 59, 59);

  List<ProductOrderLine> _lines = [];
  String? _productName;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<GetProductOrderLines>()(
        widget.productId, _start, _end,
        filter: widget.filter);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Error(:final failure):
          _error = failure.message;
        case Success(:final value):
          _lines = value;
      }
    });
    if (_productName == null) _loadName();
  }

  Future<void> _loadName() async {
    // Name comes from the product itself so it shows even with no sales.
    final result =
        await getIt<ProductRepository>().getProductById(widget.productId);
    if (!mounted) return;
    if (result case Success(:final value) when value != null) {
      setState(() => _productName = value.name);
    }
  }

  String get _periodText {
    final sameYear = _start.year == _end.year;
    final fmt = DateFormat(sameYear ? 'MMM d' : 'MMM d, y');
    return '${fmt.format(_start)} – ${DateFormat('MMM d, y').format(_end)}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profit = _lines.fold<double>(0, (s, l) => s + l.profit);
    final sales = _lines.fold<double>(0, (s, l) => s + l.sales);
    final sold = _lines.fold<int>(0, (s, l) => s + l.quantity);

    /// Every line is the same product, so they all carry the same unit.
    final unit = _lines.isEmpty ? '' : _lines.first.unit;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_periodText.toUpperCase(),
                style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
            Text(
              _productName ?? (_lines.isEmpty ? 'Product' : 'Product earnings'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: ErrorState(message: _error!, onRetry: _load))
              : ListView(
                  padding: AppSpacing.page.copyWith(top: 8),
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PROFIT',
                              style: AppTextStyles.monoLabel
                                  .copyWith(color: c.muted)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatShort(profit),
                            style: AppTextStyles.displayLarge.copyWith(
                              fontSize: 36,
                              color: profit >= 0 ? c.go : c.alert,
                            ),
                          ),
                          const SizedBox(height: 14),
                          StatRow(children: [
                            StatTile(
                                label: 'Sold',
                                value: QuantityFormatter.withUnit(sold, unit)),
                            StatTile(
                                label: 'Sales',
                                value: CurrencyFormatter.formatCompact(sales)),
                            StatTile(
                              label: unit.isEmpty ? 'Per item' : 'Per $unit',
                              value: sold == 0
                                  ? '—'
                                  : CurrencyFormatter.formatShort(
                                      profit / sold),
                              valueColor: c.go,
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SectionLabel('Orders · ${_lines.length}'),
                    const SizedBox(height: 8),
                    if (_lines.isEmpty)
                      Text(
                        'No packed or shipped orders with this product in this period.',
                        style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                      )
                    else
                      AppCard.flush(
                        child: CardList(children: [
                          for (final l in _lines)
                            CardRow(
                              title: Text(l.customerName),
                              subtitle: Text(
                                '#${l.orderId} · '
                                '${QuantityFormatter.withUnit(l.quantity, l.unit)} · '
                                '${DateFormat('MMM d').format(l.completedAt)}',
                              ),
                              trailing: Text(
                                CurrencyFormatter.formatShort(l.profit),
                                style: AppTextStyles.amount.copyWith(
                                  fontSize: 15,
                                  color: l.profit >= 0 ? c.go : c.alert,
                                ),
                              ),
                              onTap: () =>
                                  context.push(RouteNames.orderPath(l.orderId)),
                            ),
                        ]),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      'Each order\'s profit is split across its products by share of sales.',
                      style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                    ),
                  ],
                ),
    );
  }
}
