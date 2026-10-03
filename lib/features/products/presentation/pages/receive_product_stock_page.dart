import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/receive_product_stock.dart';

/// Receive stock page for standalone products (individual units, no pack math)
class ReceiveProductStockPage extends StatefulWidget {
  final int productId;

  const ReceiveProductStockPage({super.key, required this.productId});

  @override
  State<ReceiveProductStockPage> createState() =>
      _ReceiveProductStockPageState();
}

class _ReceiveProductStockPageState extends State<ReceiveProductStockPage> {
  Product? _product;
  bool _isLoading = true;
  bool _isSaving = false;
  int _quantityReceived = 1;
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final repo = getIt<ProductRepository>();
    final result = await repo.getProductById(widget.productId);

    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _isLoading = false);
          context.showSnackBar(failure.message, isError: true);
        }
      },
      (product) {
        if (mounted) {
          setState(() {
            _product = product;
            _isLoading = false;
          });
        }
      },
    );
  }

  double get _pricePerUnit {
    return double.tryParse(_priceController.text) ?? 0;
  }

  double get _newUnitCost {
    if (_product == null) return 0;
    final oldQty = _product!.quantityOnHand;
    final oldCost = _product!.unitCost;
    final newQty = _quantityReceived;
    final newPrice = _pricePerUnit;

    if (oldQty + newQty == 0) return newPrice;
    return (oldQty * oldCost + newQty * newPrice) / (oldQty + newQty);
  }

  Future<void> _submit() async {
    if (_pricePerUnit < 0) {
      context.showSnackBar('Price cannot be negative', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final receiveStock = getIt<ReceiveProductStock>();
    final result = await receiveStock(
      productId: widget.productId,
      quantity: _quantityReceived,
      pricePerUnit: _pricePerUnit,
    );

    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _isSaving = false);
          context.showSnackBar(failure.message, isError: true);
        }
      },
      (_) {
        if (mounted) {
          context.showSnackBar('Stock received!');
          context.pop(true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receive stock')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receive stock')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final prod = _product!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Receive — ${prod.name}',
            style:
                AppTextStyles.displaySmall.copyWith(color: AppColors.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Before display
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.paperHigh,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.hair),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BEFORE', style: AppTextStyles.monoSection),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${prod.quantityOnHand}',
                      style: AppTextStyles.displayMedium
                          .copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PipStrip(
                        total: prod.quantityOnHand.clamp(0, 40),
                        free: prod.quantityFree.clamp(0, 40),
                        promised: prod.quantityPromised.clamp(0, 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Unit cost: ${prod.unitCost.currency}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quantity received
          Text('QUANTITY RECEIVED', style: AppTextStyles.monoSection),
          const SizedBox(height: 8),
          StepperInput(
            value: _quantityReceived,
            min: 1,
            max: 9999,
            onChanged: (val) =>
                setState(() => _quantityReceived = val.toInt()),
          ),
          const SizedBox(height: 20),

          // Price per unit
          Text('PRICE PER UNIT', style: AppTextStyles.monoSection),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price per unit',
              prefixText: '₱ ',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          // Weighted average cost preview
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.coinSoft.withOpacity(0.3),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.coin.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEW UNIT COST (weighted avg)',
                    style: AppTextStyles.monoSection
                        .copyWith(color: AppColors.coin)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      prod.unitCost.currency,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.muted),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward,
                          size: 14, color: AppColors.muted),
                    ),
                    CurrencyText(
                      amount: _newUnitCost,
                      style: AppTextStyles.displaySmall
                          .copyWith(color: AppColors.coin),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // After preview
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.successSoft.withOpacity(0.3),
              borderRadius: BorderRadius.circular(13),
              border:
                  Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AFTER',
                    style: AppTextStyles.monoSection
                        .copyWith(color: AppColors.success)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${prod.quantityOnHand + _quantityReceived}',
                      style: AppTextStyles.displayMedium
                          .copyWith(color: AppColors.success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PipStrip(
                        total: (prod.quantityOnHand + _quantityReceived)
                            .clamp(0, 50),
                        free: (prod.quantityFree + _quantityReceived)
                            .clamp(0, 50),
                        promised: prod.quantityPromised.clamp(0, 50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.paperHigh,
          border: Border(top: BorderSide(color: AppColors.hair)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add to stock'),
            ),
          ),
        ),
      ),
    );
  }
}
