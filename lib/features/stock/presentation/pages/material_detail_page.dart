import 'package:flutter/material.dart' hide Material;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../domain/usecases/delete_material.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/adjust_stock.dart';
import '../../domain/usecases/get_material_detail.dart';

/// Material detail page — stock overview, movements, and actions
class MaterialDetailPage extends StatefulWidget {
  final int materialId;

  const MaterialDetailPage({super.key, required this.materialId});

  @override
  State<MaterialDetailPage> createState() => _MaterialDetailPageState();
}

class _MaterialDetailPageState extends State<MaterialDetailPage> {
  Material? _material;
  List<StockMovement> _movements = [];
  List<Product> _usedInProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getDetail = getIt<GetMaterialDetail>();
    final result = await getDetail(widget.materialId);

    switch (result) {
      case Error(:final failure):
        if (mounted) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        }
      case Success(:final value):
        // Load products using this material
        final productRepo = getIt<ProductRepository>();
        final productsResult =
            await productRepo.getProductsUsingMaterial(widget.materialId);
        final products = switch (productsResult) {
          Error() => <Product>[],
          Success(:final value) => value,
        };

        if (mounted) {
          setState(() {
            _material = value.material;
            _movements = value.movements;
            _usedInProducts = products;
            _isLoading = false;
          });
        }
    }
  }

  void _showAdjustDialog() {
    if (_material == null) return;
    int newQty = _material!.quantityOnHand;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.paperHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Count / Adjust',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current: ${_material!.quantityOnHand}',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              StepperInput(
                value: newQty,
                min: 0,
                max: 99999,
                onChanged: (val) => setDialogState(() => newQty = val.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.muted)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final adjustStock = getIt<AdjustStock>();
                final result =
                    await adjustStock(widget.materialId, newQty);
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Material')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Material')),
        body: Center(
          child: Text(_error!,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.alert)),
        ),
      );
    }

    if (_material == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Material')),
        body: const Center(child: Text('Material not found')),
      );
    }

    final mat = _material!;

    return Scaffold(
      appBar: AppBar(
        title: Text(mat.name,
            style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Delete material?',
                  message:
                      'This will permanently remove "${mat.name}". This cannot be undone.',
                  confirmText: 'Delete',
                  isDestructive: true,
                );
                if (confirmed && mounted) {
                  final deleteMaterial = getIt<DeleteMaterial>();
                  final result = await deleteMaterial(widget.materialId);
                  switch (result) {
                    case Error(:final failure):
                      if (mounted) {
                        context.showSnackBar(failure.message, isError: true);
                      }
                    case Success():
                      if (mounted) {
                        context.showSnackBar('Material deleted');
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stock overview card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: mat.isLowStock
                    ? AppColors.alertSoft.withOpacity(0.3)
                    : AppColors.paperHigh,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: mat.isLowStock
                      ? AppColors.alert.withOpacity(0.3)
                      : AppColors.hair,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${mat.quantityOnHand}',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: mat.isLowStock
                          ? AppColors.alert
                          : AppColors.ink,
                    ),
                  ),
                  Text(
                    'ON HAND',
                    style: AppTextStyles.monoSection,
                  ),
                  const SizedBox(height: 12),
                  PipStrip(
                    total: mat.quantityOnHand.clamp(0, 50),
                    free: mat.quantityFree.clamp(0, 50),
                    promised: mat.quantityPromised.clamp(0, 50),
                    isLow: mat.isLowStock,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Stat(label: 'Free', value: mat.quantityFree),
                      const SizedBox(width: 20),
                      _Stat(
                          label: 'Promised',
                          value: mat.quantityPromised),
                      const SizedBox(width: 20),
                      _Stat(label: 'Alert', value: mat.alertLevel),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await context.push<bool>(
                        RouteNames.receiveStock
                            .replaceFirst(':id', '${mat.id}'),
                      );
                      if (result == true && mounted) {
                        _loadData();
                      }
                    },
                    icon: const Icon(Icons.add_box_outlined, size: 16),
                    label: const Text('Receive'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showAdjustDialog,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Adjust'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Used in products
            if (_usedInProducts.isNotEmpty) ...[
              Text('USED IN', style: AppTextStyles.monoSection),
              const SizedBox(height: 8),
              ..._usedInProducts.map((p) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.paperHigh,
                      border: Border(
                          bottom: BorderSide(color: AppColors.hair)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(p.name,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.ink)),
                        ),
                        CurrencyText(
                          amount: p.sellPrice,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            // Movements
            Text('MOVEMENTS', style: AppTextStyles.monoSection),
            const SizedBox(height: 8),
            if (_movements.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('No movements yet',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.muted)),
                ),
              )
            else
              ..._movements.map((m) => _MovementRow(movement: m)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: AppTextStyles.monoLabel
                .copyWith(color: AppColors.muted, fontSize: 8)),
        const SizedBox(height: 1),
        Text('$value',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.ink)),
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  final StockMovement movement;
  const _MovementRow({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isPositive = movement.type == StockMovementType.received;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.paperHigh,
        border: Border(bottom: BorderSide(color: AppColors.hair)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPositive ? AppColors.success : AppColors.alert,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.type.displayName,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.ink),
                ),
                Text(
                  app_date.DateUtils.formatDate(movement.createdAt),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '−'}${movement.quantity}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isPositive ? AppColors.success : AppColors.alert,
            ),
          ),
        ],
      ),
    );
  }
}
