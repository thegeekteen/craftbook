import 'package:flutter/material.dart' hide Material;
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../../stock/domain/entities/material.dart';
import '../../../stock/domain/usecases/get_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/delete_product.dart';
import '../widgets/bom_editor_list.dart';

/// Product editor page — BOM editor for creating/editing products
class ProductEditorPage extends StatefulWidget {
  final int? productId;

  const ProductEditorPage({super.key, this.productId});

  @override
  State<ProductEditorPage> createState() => _ProductEditorPageState();
}

class _ProductEditorPageState extends State<ProductEditorPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  List<_EditableBomItem> _bomItems = [];
  List<Material> _availableMaterials = [];
  bool _isLoading = true;
  bool _isSaving = false;

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
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load available materials
    final getMaterials = getIt<GetMaterials>();
    final matResult = await getMaterials();
    final materials = matResult.fold((_) => <Material>[], (m) => m);

    if (widget.productId != null) {
      // Load existing product
      final productRepo = getIt<ProductRepository>();
      final productResult =
          await productRepo.getProductById(widget.productId!);
      final bomResult =
          await productRepo.getBomItems(widget.productId!);

      productResult.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _availableMaterials = materials;
              _isLoading = false;
            });
            context.showSnackBar(failure.message, isError: true);
          }
        },
        (product) {
          final bomItems = bomResult.fold(
            (_) => <BomItem>[],
            (b) => b,
          );

          if (mounted) {
            setState(() {
              _nameController.text = product!.name;
              _priceController.text = product!.sellPrice.toString();
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
        },
      );
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
              FlexibleChildListView(
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
            const SizedBox(height: 16),
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
      final result = await productRepo.createProduct(
        name: name,
        sellPrice: sellPrice,
      );

      await result.fold(
        (failure) async {
          if (mounted) {
            setState(() => _isSaving = false);
            context.showSnackBar(failure.message, isError: true);
          }
        },
        (productId) async {
          // Save BOM items
          if (_bomItems.isNotEmpty) {
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
        },
      );
    } else {
      final result = await productRepo.updateProduct(
        id: widget.productId!,
        name: name,
        sellPrice: sellPrice,
      );

      await result.fold(
        (failure) async {
          if (mounted) {
            setState(() => _isSaving = false);
            context.showSnackBar(failure.message, isError: true);
          }
        },
        (_) async {
          // Save BOM items
          await productRepo.saveBomItems(
            widget.productId!,
            _bomItems
                .map((b) => BomItemInput(
                      materialId: b.materialId,
                      quantityRequired: b.quantityRequired,
                    ))
                .toList(),
          );

          if (mounted) {
            setState(() => _isSaving = false);
            context.showSnackBar('Product updated!');
            Navigator.of(context).pop(true);
          }
        },
      );
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
                        'This will permanently remove this product and its BOM. This cannot be undone.',
                    confirmText: 'Delete',
                    isDestructive: true,
                  );
                  if (confirmed && mounted) {
                    final deleteProduct = getIt<DeleteProduct>();
                    final result =
                        await deleteProduct(widget.productId!);
                    result.fold(
                      (failure) {
                        if (mounted) {
                          context.showSnackBar(failure.message,
                              isError: true);
                        }
                      },
                      (_) {
                        if (mounted) {
                          context.showSnackBar('Product deleted');
                          context.pop(true);
                        }
                      },
                    );
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
          const SizedBox(height: 24),

          // BOM items
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
                    label: 'Material cost',
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

/// A simple widget that acts like ListView.builder with shrinkWrap
class FlexibleChildListView extends StatelessWidget {
  final bool shrinkWrap;
  final List<Widget> children;

  const FlexibleChildListView({
    super.key,
    this.shrinkWrap = true,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        shrinkWrap: shrinkWrap,
        children: children,
      ),
    );
  }
}
