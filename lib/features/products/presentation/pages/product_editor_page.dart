import 'package:flutter/material.dart' hide Material;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../domain/usecases/adjust_product_stock.dart';
import '../../../stock/domain/entities/material.dart';
import '../../../stock/domain/usecases/get_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/delete_product.dart';

class ProductEditorPage extends StatefulWidget {
  final int? productId;

  const ProductEditorPage({super.key, this.productId});

  @override
  State<ProductEditorPage> createState() => _ProductEditorPageState();
}

class _ProductEditorPageState extends State<ProductEditorPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _alertLevelController = TextEditingController();
  final _initialQtyController = TextEditingController(text: '0');
  List<_EditableBomItem> _bomItems = [];
  List<Material> _availableMaterials = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isStandalone = false;

  // Existing product state (loaded from DB)
  int _existingQuantityOnHand = 0;
  double _existingUnitCost = 0;

  bool get _isNew => widget.productId == null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _unitCostController.dispose();
    _alertLevelController.dispose();
    _initialQtyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final getMaterials = getIt<GetMaterials>();
    final matResult = await getMaterials();
    final materials = switch (matResult) {
      Error() => <Material>[],
      Success(:final value) => value,
    };

    if (widget.productId != null) {
      final productRepo = getIt<ProductRepository>();
      final productResult =
          await productRepo.getProductById(widget.productId!);
      final bomResult = await productRepo.getBomItems(widget.productId!);

      switch (productResult) {
        case Error(:final failure):
          if (mounted) {
            setState(() {
              _availableMaterials = materials;
              _isLoading = false;
            });
            context.showSnackBar(failure.message, isError: true);
          }
        case Success(:final value):
          final product = value;
          final bomItems = switch (bomResult) {
            Error() => <BomItem>[],
            Success(:final value) => value,
          };

          if (mounted) {
            setState(() {
              _nameController.text = product!.name;
              _priceController.text = product.sellPrice.toString();
              _isStandalone = product.isStandalone;
              _existingQuantityOnHand = product.quantityOnHand;
              _existingUnitCost = product.unitCost;
              _unitCostController.text =
                  product.unitCost > 0 ? product.unitCost.toStringAsFixed(2) : '';
              _alertLevelController.text =
                  product.alertLevel > 0 ? product.alertLevel.toString() : '';
              _availableMaterials = materials;
              _bomItems = bomItems
                  .map((b) => _EditableBomItem(
                        materialId: b.materialId,
                        materialName: b.materialName,
                        materialUnitCost: b.materialUnitCost,
                        quantityRequired: b.quantityRequired,
                      ))
                  .toList();
              _isLoading = false;
            });
          }
      }
    } else {
      if (mounted) {
        setState(() {
          _availableMaterials = materials;
          _isLoading = false;
        });
      }
    }
  }

  double get _totalMaterialCost {
    if (_isStandalone) {
      return double.tryParse(_unitCostController.text) ?? 0;
    }
    return _bomItems.fold(
        0.0, (sum, item) => sum + item.quantityRequired * item.materialUnitCost);
  }

  double get _sellPrice {
    return double.tryParse(_priceController.text) ?? 0;
  }

  double get _profit => _sellPrice - _totalMaterialCost;

  void _showAddMaterialSheet() {
    final existingIds = _bomItems.map((b) => b.materialId).toSet();
    final available =
        _availableMaterials.where((m) => !existingIds.contains(m.id!)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: AppColors.paperHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.hair,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Add material',
                  style: AppTextStyles.displaySmall
                      .copyWith(color: AppColors.ink)),
            ),
            if (available.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('All materials already added',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.muted)),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: available
                      .map((m) => ListTile(
                            title: Text(m.name,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.ink)),
                            subtitle: CurrencyText(
                              amount: m.unitCost,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.muted),
                            ),
                            onTap: () {
                              setState(() {
                                _bomItems.add(_EditableBomItem(
                                  materialId: m.id!,
                                  materialName: m.name,
                                  materialUnitCost: m.unitCost,
                                  quantityRequired: 1,
                                ));
                              });
                              Navigator.pop(ctx);
                            },
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAdjustDialog() {
    int adjustedQty = _existingQuantityOnHand;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.paperHigh,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Adjust stock',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current: $_existingQuantityOnHand units',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              StepperInput(
                value: adjustedQty,
                min: 0,
                max: 99999,
                onChanged: (val) =>
                    setDialogState(() => adjustedQty = val.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  Text('Cancel', style: TextStyle(color: AppColors.muted)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final adjustStock = getIt<AdjustProductStock>();
                final result = await adjustStock(
                  productId: widget.productId!,
                  newQuantityOnHand: adjustedQty,
                );
                switch (result) {
                  case Error(:final failure):
                    if (mounted) {
                      context.showSnackBar(failure.message, isError: true);
                    }
                  case Success():
                    if (mounted) {
                      context.showSnackBar('Stock adjusted');
                      _loadData();
                    }
                }
              },
              child: const Text('Adjust'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final sellPrice = _sellPrice;

    if (name.isEmpty) {
      context.showSnackBar('Product name is required', isError: true);
      return;
    }
    if (sellPrice <= 0) {
      context.showSnackBar('Sell price must be > 0', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final productRepo = getIt<ProductRepository>();

    if (_isNew) {
      final initialQty = int.tryParse(_initialQtyController.text) ?? 0;
      final initialCost = double.tryParse(_unitCostController.text) ?? 0.0;

      final result = await productRepo.createProduct(
        name: name,
        sellPrice: sellPrice,
        isStandalone: _isStandalone,
        initialQuantity: _isStandalone ? initialQty : 0,
        initialUnitCost: _isStandalone ? initialCost : 0,
      );

      switch (result) {
        case Error(:final failure):
          if (mounted) {
            setState(() => _isSaving = false);
            context.showSnackBar(failure.message, isError: true);
          }
        case Success(:final value):
          final productId = value;
          if (!_isStandalone && _bomItems.isNotEmpty) {
            await productRepo.saveBomItems(
              productId,
              _bomItems
                  .map((b) => BomItemInput(
                        materialId: b.materialId,
                        quantityRequired: b.quantityRequired,
                      ))
                  .toList(),
            );
          }

          if (mounted) {
            setState(() => _isSaving = false);
            context.showSnackBar('Product created!');
            Navigator.of(context).pop(true);
          }
      }
    } else {
      final alertLevel = int.tryParse(_alertLevelController.text) ?? 0;

      final result = await productRepo.updateProduct(
        id: widget.productId!,
        name: name,
        sellPrice: sellPrice,
        isStandalone: _isStandalone,
        alertLevel: _isStandalone ? alertLevel : 0,
      );

      switch (result) {
        case Error(:final failure):
          if (mounted) {
            setState(() => _isSaving = false);
            context.showSnackBar(failure.message, isError: true);
          }
        case Success():
          if (!_isStandalone) {
            await productRepo.saveBomItems(
              widget.productId!,
              _bomItems
                  .map((b) => BomItemInput(
                        materialId: b.materialId,
                        quantityRequired: b.quantityRequired,
                      ))
                  .toList(),
            );
          }

          if (mounted) {
            setState(() => _isSaving = false);
            context.showSnackBar('Product updated!');
            Navigator.of(context).pop(true);
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNew ? 'New product' : 'Edit product',
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        ),
        actions: [
          if (!_isNew)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: 'Delete product?',
                    message:
                        'This will permanently remove this product. This cannot be undone.',
                    confirmText: 'Delete',
                    isDestructive: true,
                  );
                  if (confirmed && mounted) {
                    final deleteProduct = getIt<DeleteProduct>();
                    final result =
                        await deleteProduct(widget.productId!);
                    switch (result) {
                      case Error(:final failure):
                        if (mounted) {
                          context.showSnackBar(failure.message,
                              isError: true);
                        }
                      case Success():
                        if (mounted) {
                          context.showSnackBar('Product deleted');
                          context.pop(true);
                        }
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          color: AppColors.alert, size: 20),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: AppColors.alert)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Product name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Product name'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // Sell price
          TextField(
            controller: _priceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Sell price',
              prefixText: '₱ ',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Product type toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.paperHigh,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.hair),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isStandalone ? 'Standalone product' : 'BOM product',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.ink),
                      ),
                      Text(
                        _isStandalone
                            ? 'Buy & resell as-is, track own stock'
                            : 'Built from materials using BOM',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isStandalone,
                  onChanged: (val) => setState(() => _isStandalone = val),
                  activeColor: AppColors.coin,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_isStandalone) ..._buildStandaloneSection(),
          if (!_isStandalone) ..._buildBomSection(),
          const SizedBox(height: 24),

          // Cost/profit card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.coinSoft.withOpacity(0.3),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.coin.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _CostRow(
                    label: _isStandalone ? 'Unit cost' : 'Material cost',
                    amount: _totalMaterialCost,
                    color: AppColors.alert),
                _CostRow(
                    label: 'Sell price',
                    amount: _sellPrice,
                    color: AppColors.success),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: AppColors.hair),
                ),
                _CostRow(
                    label: 'Profit',
                    amount: _profit,
                    color: _profit >= 0
                        ? AppColors.success
                        : AppColors.alert,
                    isBold: true),
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
              onPressed: _isSaving ? null : _save,
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
                  : Text(_isNew ? 'Create product' : 'Save changes'),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStandaloneSection() {
    return [
      if (!_isNew) ...[
        // Stock overview for existing standalone product
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.paperHigh,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.hair),
          ),
          child: Row(
            children: [
              _StockStat(
                label: 'On hand',
                value: _existingQuantityOnHand.toString(),
                color: AppColors.ink,
              ),
              const SizedBox(width: 24),
              _StockStat(
                label: 'Unit cost',
                value: '₱${_existingUnitCost.toStringAsFixed(2)}',
                color: AppColors.coin,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Receive & Adjust buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final route = RouteNames.receiveProductStock
                      .replaceFirst(':id', '${widget.productId!}');
                  final result = await context.push<bool>(route);
                  if (result == true && mounted) {
                    _loadData();
                  }
                },
                icon: const Icon(Icons.add_box_outlined, size: 18),
                label: const Text('Receive'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: const BorderSide(color: AppColors.success),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showAdjustDialog(),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Adjust'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coin,
                  side: const BorderSide(color: AppColors.coin),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],

      // Unit cost (for new products)
      if (_isNew) ...[
        TextField(
          controller: _unitCostController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Unit cost',
            prefixText: '₱ ',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _initialQtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Initial stock quantity',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
      ],

      // Alert level
      TextField(
        controller: _alertLevelController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Low stock alert level',
          hintText: 'e.g. 5',
        ),
      ),
    ];
  }

  List<Widget> _buildBomSection() {
    return [
      Row(
        children: [
          Text('MATERIALS', style: AppTextStyles.monoSection),
          const Spacer(),
          TextButton.icon(
            onPressed: _showAddMaterialSheet,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      _EditableBomList(
        items: _bomItems,
        onChanged: () => setState(() {}),
        onRemoved: (index) {
          setState(() => _bomItems.removeAt(index));
        },
      ),
    ];
  }
}

class _StockStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StockStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.displaySmall.copyWith(color: color)),
      ],
    );
  }
}

class _EditableBomItem {
  int materialId;
  String materialName;
  double materialUnitCost;
  int quantityRequired;

  _EditableBomItem({
    required this.materialId,
    required this.materialName,
    required this.materialUnitCost,
    required this.quantityRequired,
  });

  double get lineCost => quantityRequired * materialUnitCost;
}

class _EditableBomList extends StatelessWidget {
  final List<_EditableBomItem> items;
  final VoidCallback onChanged;
  final ValueChanged<int> onRemoved;

  const _EditableBomList({
    required this.items,
    required this.onChanged,
    required this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.paperHigh,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.hair),
        ),
        child: Center(
          child: Text(
            'No materials added yet',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.paperHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.hair),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.materialName,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.ink)),
                      CurrencyText(
                        amount: item.materialUnitCost,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                StepperInput(
                  value: item.quantityRequired,
                  min: 1,
                  max: 999,
                  onChanged: (val) {
                    item.quantityRequired = val.toInt();
                    onChanged();
                  },
                ),
                const SizedBox(width: 8),
                CurrencyText(
                  amount: item.lineCost,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.coin),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => onRemoved(index),
                  icon: const Icon(Icons.close, size: 16,
                      color: AppColors.muted),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          );
        }),

        // Total
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Total: ', style: AppTextStyles.bodySmall),
              CurrencyText(
                amount: items.fold(0.0, (sum, i) => sum + i.lineCost),
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.coin),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isBold;

  const _CostRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.bodyLarge.copyWith(color: AppColors.ink)
                : AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
          CurrencyText(
            amount: amount,
            style: (isBold ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium)
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
