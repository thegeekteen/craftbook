import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/receive_product_stock.dart';

/// Receive units of a resell product, with a live preview of the new count
/// and weighted-average unit cost.
class ReceiveProductStockPage extends StatefulWidget {
  final int productId;

  const ReceiveProductStockPage({super.key, required this.productId});

  @override
  State<ReceiveProductStockPage> createState() => _ReceiveProductStockPageState();
}

class _ReceiveProductStockPageState extends State<ReceiveProductStockPage> {
  Product? _product;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  int _quantity = 1;
  final _price = TextEditingController();

  @override
  void initState() {
    super.initState();
    _price.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await getIt<ProductRepository>().getProductById(widget.productId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Error(:final failure):
          _error = failure.message;
        case Success(:final value):
          _product = value;
          if (value != null && value.unitCost > 0) {
            _price.text = value.unitCost.toStringAsFixed(2);
          }
      }
    });
  }

  double get _pricePerUnit => double.tryParse(_price.text) ?? 0;

  double get _newUnitCost {
    final p = _product!;
    final total = p.quantityOnHand + _quantity;
    if (total == 0) return _pricePerUnit;
    return (p.quantityOnHand * p.unitCost + _quantity * _pricePerUnit) / total;
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final result = await getIt<ReceiveProductStock>()(
      productId: widget.productId,
      quantity: _quantity,
      pricePerUnit: _pricePerUnit,
    );
    if (!mounted) return;
    switch (result) {
      case Error(:final failure):
        setState(() => _saving = false);
        context.showSnackBar(failure.message, isError: true);
      case Success():
        context.showSnackBar('Added $_quantity to ${_product!.name}');
        context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: ErrorState(message: _error ?? 'Product not found', onRetry: _load)),
      );
    }
    final c = context.colors;
    final p = _product!;
    final costUp = _newUnitCost > p.unitCost + 0.005;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('RECEIVE', style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      body: ListView(
        padding: AppSpacing.page.copyWith(top: 8),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('QUANTITY RECEIVED', style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
                    ),
                    StepperInput(
                      value: _quantity,
                      min: 1,
                      max: 9999,
                      onChanged: (v) => setState(() => _quantity = v.toInt()),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  decoration: const InputDecoration(labelText: 'Price per piece', prefixText: '₱ '),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AFTER RECEIVING', style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${p.quantityOnHand}', style: AppTextStyles.amount.copyWith(color: c.muted, fontSize: 20)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, size: 18, color: c.muted),
                    ),
                    Text(
                      '${p.quantityOnHand + _quantity}',
                      style: AppTextStyles.displayMedium.copyWith(color: c.go, fontSize: 32),
                    ),
                    const SizedBox(width: 6),
                    Text('PCS', style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
                  ],
                ),
                const SizedBox(height: 10),
                PipStrip(
                  total: p.quantityOnHand + _quantity,
                  free: p.quantityFree,
                  promised: p.quantityPromised,
                  incoming: _quantity,
                  alertLevel: p.alertLevel,
                ),
                const SizedBox(height: 12),
                Divider(color: c.hair),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text('Unit cost (weighted)', style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
                    ),
                    Text('${CurrencyFormatter.format(p.unitCost)} → ',
                        style: AppTextStyles.bodyMedium.copyWith(color: c.muted)),
                    Text(
                      CurrencyFormatter.format(_newUnitCost),
                      style: AppTextStyles.amount.copyWith(color: costUp ? c.alert : c.coin, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _saving ? null : _submit,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text('Add $_quantity to stock'),
          ),
        ),
      ]),
    );
  }
}
