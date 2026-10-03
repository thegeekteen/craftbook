import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../../stock/domain/entities/material.dart';
import '../../../stock/domain/usecases/get_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/adjust_product_stock.dart';
import '../../domain/usecases/delete_product.dart';

/// Create or edit a product. Handmade products list the materials one piece
/// uses; resell products track their own stock.
class ProductEditorPage extends StatefulWidget {
  final int? productId;

  const ProductEditorPage({super.key, this.productId});

  @override
  State<ProductEditorPage> createState() => _ProductEditorPageState();
}

class _ProductEditorPageState extends State<ProductEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _unitCost = TextEditingController();
  final _alertLevel = TextEditingController();
  final _initialQty = TextEditingController(text: '0');

  List<_EditableBomItem> _bom = [];
  List<Material> _materials = [];
  Product? _product;
  bool _isStandalone = false;
  bool _isActive = true;
  bool _loading = true;
  bool _saving = false;
  bool _changed = false;
  String? _error;

  bool get _isNew => widget.productId == null;

  @override
  void initState() {
    super.initState();
    for (final ctrl in [_price, _unitCost]) {
      ctrl.addListener(() => setState(() {}));
    }
    _load();
  }

  @override
  void dispose() {
    for (final ctrl in [_name, _price, _unitCost, _alertLevel, _initialQty]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  static String _money(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  Future<void> _load() async {
    final matResult = await getIt<GetMaterials>()();
    final materials = switch (matResult) {
      Success(:final value) => value,
      Error() => <Material>[],
    };

    if (_isNew) {
      if (!mounted) return;
      setState(() {
        _materials = materials;
        _loading = false;
      });
      return;
    }

    final repo = getIt<ProductRepository>();
    final productResult = await repo.getProductById(widget.productId!);
    final bomResult = await repo.getBomItems(widget.productId!);
    if (!mounted) return;
    setState(() {
      _materials = materials;
      _loading = false;
      switch (productResult) {
        case Error(:final failure):
          _error = failure.message;
        case Success(:final value) when value == null:
          _error = 'Product not found';
        case Success(:final value):
          final p = value!;
          _product = p;
          _name.text = p.name;
          _price.text = _money(p.sellPrice);
          _isStandalone = p.isStandalone;
          _isActive = p.isActive;
          _unitCost.text = p.unitCost > 0 ? _money(p.unitCost) : '';
          _alertLevel.text = p.alertLevel > 0 ? '${p.alertLevel}' : '';
          _bom = switch (bomResult) {
            Success(:final value) => [
                for (final BomItem b in value)
                  _EditableBomItem(
                    materialId: b.materialId,
                    materialName: b.materialName,
                    unitCost: b.materialUnitCost,
                    quantity: b.quantityRequired,
                  ),
              ],
            Error() => [],
          };
      }
    });
  }

  double get _sellPrice => double.tryParse(_price.text) ?? 0;

  double get _cost => _isStandalone
      ? (_isNew ? double.tryParse(_unitCost.text) ?? 0 : _product?.unitCost ?? 0)
      : _bom.fold(0.0, (s, b) => s + b.quantity * b.unitCost);

  Future<void> _addMaterial() async {
    final taken = _bom.map((b) => b.materialId).toSet();
    final options = _materials.where((m) => !taken.contains(m.id)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    var query = '';
    final picked = await showAppSheet<Material>(
      context: context,
      title: 'Add material',
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          final c = sheetContext.colors;
          final visible = options.where((m) => m.name.toLowerCase().contains(query)).toList();
          if (options.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: _materials.isEmpty ? 'No materials yet' : 'All materials added',
              message: _materials.isEmpty ? 'Add materials under Stock first.' : null,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (options.length > 6) ...[
                AppSearchField(
                  hint: 'Search materials',
                  onChanged: (v) => setSheet(() => query = v.trim().toLowerCase()),
                ),
                const SizedBox(height: 8),
              ],
              for (final m in visible)
                InkWell(
                  onTap: () => Navigator.pop(sheetContext, m),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(m.name, style: AppTextStyles.bodyLarge.copyWith(color: c.ink)),
                        ),
                        Text(
                          '${CurrencyFormatter.format(m.unitCost)}/pc',
                          style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.add_circle_outline_rounded, color: c.go, size: 22),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
    if (picked == null) return;
    setState(() => _bom.add(_EditableBomItem(
          materialId: picked.id!,
          materialName: picked.name,
          unitCost: picked.unitCost,
          quantity: 1,
        )));
  }

  Future<void> _count() async {
    final p = _product!;
    var counted = p.quantityOnHand;
    final save = await showAppSheet<bool>(
      context: context,
      title: 'Count stock',
      subtitle: 'Set how many are actually on the shelf.',
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: StepperInput(
                value: counted,
                min: 0,
                max: 99999,
                onChanged: (v) => setSheet(() => counted = v.toInt()),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: counted == p.quantityOnHand ? null : () => Navigator.pop(sheetContext, true),
              child: const Text('Save count'),
            ),
          ],
        ),
      ),
    );
    if (save != true || !mounted) return;
    final result = await getIt<AdjustProductStock>()(productId: p.id!, newQuantityOnHand: counted);
    if (!mounted) return;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
      case Success():
        context.showSnackBar('Stock set to $counted');
        _changed = true;
        _load();
    }
  }

  Future<void> _receive() async {
    final changed = await context.push<bool>(RouteNames.receiveProductStockPath(widget.productId!));
    if (changed == true && mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = getIt<ProductRepository>();
    final name = _name.text.trim();
    final alertLevel = int.tryParse(_alertLevel.text) ?? 0;
    final bomInputs = [
      for (final b in _bom) BomItemInput(materialId: b.materialId, quantityRequired: b.quantity),
    ];

    Result<void> outcome;
    if (_isNew) {
      final created = await repo.createProduct(
        name: name,
        sellPrice: _sellPrice,
        isStandalone: _isStandalone,
        initialQuantity: _isStandalone ? int.tryParse(_initialQty.text) ?? 0 : 0,
        initialUnitCost: _isStandalone ? double.tryParse(_unitCost.text) ?? 0 : 0,
      );
      switch (created) {
        case Error(:final failure):
          outcome = Error(failure);
        case Success(value: final id):
          // createProduct has no alert level; set it right after.
          if (_isStandalone && alertLevel > 0) {
            await repo.updateProduct(id: id, alertLevel: alertLevel);
          }
          outcome = _isStandalone || bomInputs.isEmpty
              ? const Success(null)
              : await repo.saveBomItems(id, bomInputs);
      }
    } else {
      final updated = await repo.updateProduct(
        id: widget.productId!,
        name: name,
        sellPrice: _sellPrice,
        isStandalone: _isStandalone,
        isActive: _isActive,
        alertLevel: _isStandalone ? alertLevel : 0,
      );
      outcome = switch (updated) {
        Error() => updated,
        Success() => _isStandalone ? updated : await repo.saveBomItems(widget.productId!, bomInputs),
      };
    }

    if (!mounted) return;
    switch (outcome) {
      case Error(:final failure):
        setState(() => _saving = false);
        context.showSnackBar(failure.message, isError: true);
      case Success():
        context.showSnackBar(_isNew ? '$name added' : 'Changes saved');
        context.pop(true);
    }
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete ${_name.text.trim()}?',
      message: "This can't be undone. Products that appear in orders can't be deleted; hide them instead.",
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    final result = await getIt<DeleteProduct>()(widget.productId!);
    if (!mounted) return;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
      case Success():
        context.showSnackBar('Product deleted');
        context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final back = BackButton(onPressed: () => context.pop(_changed));
    if (_loading) {
      return Scaffold(appBar: AppBar(leading: back), body: const Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(appBar: AppBar(leading: back), body: Center(child: ErrorState(message: _error!, onRetry: _load)));
    }
    final c = context.colors;
    final money = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))];
    final digits = [FilteringTextInputFormatter.digitsOnly];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: back,
          title: Text(_isNew ? 'New product' : 'Edit product'),
          actions: [
            if (!_isNew)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (v) {
                  if (v == 'delete') _delete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded, size: 20, color: c.alert),
                      const SizedBox(width: 10),
                      Text('Delete product', style: TextStyle(color: c.alert)),
                    ]),
                  ),
                ],
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.page.copyWith(top: 8),
            children: [
              TextFormField(
                controller: _name,
                autofocus: _isNew,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: money,
                decoration: const InputDecoration(labelText: 'Sell price', prefixText: '₱ '),
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter a price above 0' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('Handmade'), icon: Icon(Icons.content_cut_rounded, size: 18)),
                    ButtonSegment(value: true, label: Text('Resell'), icon: Icon(Icons.inventory_2_outlined, size: 18)),
                  ],
                  selected: {_isStandalone},
                  onSelectionChanged: (s) => setState(() => _isStandalone = s.first),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                child: Text(
                  _isStandalone
                      ? 'Bought ready-made. Tracks its own stock.'
                      : 'Made from materials. Stock comes from what you can build.',
                  style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                ),
              ),
              if (_isStandalone) ..._buildResell(money, digits) else ..._buildHandmade(),
              const SizedBox(height: 12),
              _ProfitCard(sellPrice: _sellPrice, cost: _cost, isStandalone: _isStandalone),
              if (!_isNew) ...[
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('Show in new orders'),
                    subtitle: const Text('Turn off to retire a product without deleting it.'),
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: BottomActionBar(children: [
          Expanded(
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : (_isNew ? 'Add product' : 'Save changes')),
            ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildHandmade() {
    final c = context.colors;
    return [
      SectionLabel(
        'Materials per piece',
        padding: const EdgeInsets.fromLTRB(2, 16, 0, 0),
        trailing: SectionAction(label: 'Add', icon: Icons.add_rounded, onTap: _addMaterial),
      ),
      const SizedBox(height: 8),
      if (_bom.isEmpty)
        AppCard(
          onTap: _addMaterial,
          child: Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: c.go),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Add the materials one piece uses so the app can work out cost and reserve stock.',
                  style: AppTextStyles.bodySmall.copyWith(color: c.muted, fontSize: 13),
                ),
              ),
            ],
          ),
        )
      else ...[
        AppCard.flush(
          child: CardList(children: [
            for (final b in _bom)
              CardRow(
                title: Text(b.materialName),
                subtitle: Text.rich(TextSpan(children: [
                  TextSpan(text: '${CurrencyFormatter.format(b.unitCost)} each · '),
                  TextSpan(
                    text: CurrencyFormatter.format(b.quantity * b.unitCost),
                    style: TextStyle(color: c.coin, fontWeight: FontWeight.w600),
                  ),
                ])),
                trailing: StepperInput(
                  value: b.quantity,
                  min: 0,
                  onChanged: (v) => setState(() {
                    if (v.toInt() == 0) {
                      _bom.remove(b);
                    } else {
                      b.quantity = v.toInt();
                    }
                  }),
                ),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
          child: Text(
            'Set a quantity to 0 to remove a material.',
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildResell(List<TextInputFormatter> money, List<TextInputFormatter> digits) {
    final c = context.colors;
    final p = _product;
    return [
      const SectionLabel('Stock', padding: EdgeInsets.fromLTRB(2, 16, 2, 0)),
      const SizedBox(height: 8),
      if (!_isNew && p != null) ...[
        AppCard(
          child: StatRow(children: [
            StatTile(
              label: 'On hand',
              value: '${p.quantityOnHand}',
              valueColor: p.isLowStock ? c.alert : null,
            ),
            StatTile(label: 'Free', value: '${p.quantityFree < 0 ? 0 : p.quantityFree}', valueColor: c.go),
            StatTile(label: 'Unit cost', value: CurrencyFormatter.format(p.unitCost)),
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _receive,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Receive'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _count,
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text('Count'),
            ),
          ),
        ]),
        const SizedBox(height: 12),
      ] else ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _unitCost,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: money,
                decoration: const InputDecoration(labelText: 'Cost per piece', prefixText: '₱ '),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _initialQty,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                decoration: const InputDecoration(labelText: 'On hand now'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
      TextFormField(
        controller: _alertLevel,
        keyboardType: TextInputType.number,
        inputFormatters: digits,
        decoration: const InputDecoration(
          labelText: 'Reorder at (optional)',
          helperText: 'Shows a low-stock warning at this level.',
        ),
      ),
    ];
  }
}

class _ProfitCard extends StatelessWidget {
  final double sellPrice;
  final double cost;
  final bool isStandalone;

  const _ProfitCard({required this.sellPrice, required this.cost, required this.isStandalone});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final parts = MoneyParts(sales: sellPrice, materials: cost, fees: 0, shipping: 0);
    final positive = parts.profit >= 0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text('PROFIT PER PIECE', style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
              ),
              Text(
                CurrencyFormatter.formatShort(parts.profit),
                style: AppTextStyles.displayMedium.copyWith(fontSize: 26, color: positive ? c.go : c.alert),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MoneyBreakdownBar(parts: parts),
          const SizedBox(height: 8),
          Text(
            '${CurrencyFormatter.format(cost)} ${isStandalone ? 'cost' : 'materials'} · '
            '${(parts.margin * 100).round()}% margin · before channel fees',
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}

class _EditableBomItem {
  final int materialId;
  final String materialName;
  final double unitCost;
  int quantity;

  _EditableBomItem({
    required this.materialId,
    required this.materialName,
    required this.unitCost,
    required this.quantity,
  });
}
