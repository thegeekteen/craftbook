import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../domain/entities/material.dart';
import '../../domain/usecases/get_material_detail.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';

/// Receive stock page — add new stock to a material
class ReceiveStockPage extends StatefulWidget {
  final int materialId;

  const ReceiveStockPage({super.key, required this.materialId});

  @override
  State<ReceiveStockPage> createState() => _ReceiveStockPageState();
}

class _ReceiveStockPageState extends State<ReceiveStockPage> {
  Material? _material;
  bool _isLoading = true;
  int _packsReceived = 1;
  int _packSize = 0;
  final _priceController = TextEditingController();
  final _supplierController = TextEditingController();
  final _packSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMaterial();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _supplierController.dispose();
    _packSizeController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterial() async {
    final getDetail = getIt<GetMaterialDetail>();
    final result = await getDetail(widget.materialId);

    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _isLoading = false);
          context.showSnackBar(failure.message, isError: true);
        }
      },
      (detail) {
        if (mounted) {
          setState(() {
            _material = detail.material;
            _packSize = detail.material.packSize;
            _packSizeController.text = detail.material.packSize.toString();
            _isLoading = false;
          });
        }
      },
    );
  }

  double get _pricePerPack {
    return double.tryParse(_priceController.text) ?? 0;
  }

  int get _totalPcs {
    return _packsReceived * _packSize;
  }

  double get _newUnitCost {
    if (_material == null) return 0;
    final oldQty = _material!.quantityOnHand;
    final oldCost = _material!.unitCost;
    final newQty = _totalPcs;
    final newPrice = _packSize > 0 ? _pricePerPack / _packSize : 0.0;

    if (oldQty + newQty == 0) return newPrice;
    return (oldQty * oldCost + newQty * newPrice) / (oldQty + newQty);
  }

  void _submit() {
    if (_pricePerPack <= 0) {
      context.showSnackBar('Enter a valid price', isError: true);
      return;
    }

    context.read<MaterialsBloc>().add(ReceiveStockEvent(
          materialId: widget.materialId,
          packsReceived: _packsReceived,
          pricePerPack: _pricePerPack,
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receive stock')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_material == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receive stock')),
        body: const Center(child: Text('Material not found')),
      );
    }

    final mat = _material!;

    return BlocConsumer<MaterialsBloc, MaterialsState>(
      listener: (context, state) {
        if (state is StockReceived) {
          context.showSnackBar('Stock received!');
          context.pop(true);
        }
        if (state is MaterialsError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Receive — ${mat.name}',
                style: AppTextStyles.displaySmall
                    .copyWith(color: AppColors.ink)),
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
                          '${mat.quantityOnHand}',
                          style: AppTextStyles.displayMedium
                              .copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(width: 12),
                        PipStrip(
                          total: mat.quantityOnHand.clamp(0, 40),
                          free: mat.quantityFree.clamp(0, 40),
                          promised: mat.quantityPromised.clamp(0, 40),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unit cost: ${mat.unitCost.currency}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quantity per pack (read-only)
              Text('QUANTITY PER PACK', style: AppTextStyles.monoSection),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.paperHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.hair),
                ),
                child: Text(
                  '$_packSize pcs per pack',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.ink),
                ),
              ),
              const SizedBox(height: 20),

              // Packs received
              Text('PACKS RECEIVED', style: AppTextStyles.monoSection),
              const SizedBox(height: 8),
              Row(
                children: [
                  StepperInput(
                    value: _packsReceived,
                    min: 1,
                    max: 999,
                    onChanged: (val) =>
                        setState(() => _packsReceived = val.toInt()),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '= $_totalPcs pcs',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price per pack
              Text('PRICE PER PACK', style: AppTextStyles.monoSection),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '₱ ',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Supplier
              Text('SUPPLIER (optional)', style: AppTextStyles.monoSection),
              const SizedBox(height: 8),
              TextField(
                controller: _supplierController,
                decoration: const InputDecoration(labelText: 'Supplier'),
              ),
              const SizedBox(height: 24),

              // Weighted average cost preview
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.coinSoft.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(13),
                  border:
                      Border.all(color: AppColors.coin.withOpacity(0.3)),
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
                          mat.unitCost.currency,
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
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AFTER',
                        style: AppTextStyles.monoSection.copyWith(
                            color: AppColors.success)),
                    const SizedBox(height: 8),
                    Text(
                      '${mat.quantityOnHand + _totalPcs}',
                      style: AppTextStyles.displayMedium
                          .copyWith(color: AppColors.success),
                    ),
                    const SizedBox(height: 4),
                    PipStrip(
                      total: (mat.quantityOnHand + _totalPcs).clamp(0, 50),
                      free: (mat.quantityFree + _totalPcs).clamp(0, 50),
                      promised: mat.quantityPromised.clamp(0, 50),
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
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add to stock'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
