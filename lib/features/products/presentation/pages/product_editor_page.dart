import 'package:flutter/material.dart' hide Material;
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
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../../stock/domain/entities/material.dart';
import '../../../stock/domain/usecases/get_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/set_product_photo.dart';
import '../../domain/usecases/update_product.dart';
import '../widgets/product_photo_field.dart';
import '../widgets/product_profit_card.dart';

/// Create or edit a product. Handmade products list the materials one piece
/// uses; resell products track their own stock. Viewing an existing product
/// happens on ProductDetailPage.
class ProductEditorPage extends StatefulWidget {
  final int? productId;

  const ProductEditorPage({super.key, this.productId});

  @override
  State<ProductEditorPage> createState() => _ProductEditorPageState();
}

class _ProductEditorPageState extends State<ProductEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _unitCost = TextEditingController();
  final _alertLevel = TextEditingController();
  final _initialQty = TextEditingController(text: '0');

  List<_EditableBomItem> _bom = [];
  List<Material> _materials = [];
  Product? _product;
  bool _isStandalone = false;
  Uint8List? _photo;

  /// Only write the photo when it changed; it is the largest column.
  bool _photoDirty = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  /// Why the Handmade/Resell switch is locked, or null when it's free.
  /// Flipping the type would orphan the BOM, stock or order history.
  String? _typeLockReason;

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
    for (final ctrl in [
      _name,
      _description,
      _price,
      _unitCost,
      _alertLevel,
      _initialQty
    ]) {
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
    final inOrders = await repo.hasOrdersUsingProduct(widget.productId!);
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
          _description.text = p.description ?? '';
          _price.text = _money(p.sellPrice);
          _isStandalone = p.isStandalone;
          _photo = p.photo;
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
                    makes: b.makes,
                  ),
              ],
            Error() => [],
          };
          _typeLockReason = switch (inOrders) {
            Success(value: true) => 'Used in orders, so its type is fixed.',
            _ when p.quantityOnHand > 0 || p.quantityPromised > 0 =>
              'It has stock on hand or reserved, so its type is fixed.',
            _ when !p.isStandalone && _bom.isNotEmpty =>
              'Remove its materials first to switch it to Resell.',
            _ => null,
          };
      }
    });
  }

  double get _sellPrice => double.tryParse(_price.text) ?? 0;

  double get _cost => _isStandalone
      ? double.tryParse(_unitCost.text) ?? 0
      : _bom.fold(0.0, (s, b) => s + b.quantity * b.unitCost);

  Future<void> _addMaterial() async {
    final taken = _bom.map((b) => b.materialId).toSet();
    final options = _materials
        .where((m) => !m.isArchived && !taken.contains(m.id))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    var query = '';
    final picked = await showAppSheet<Material>(
      context: context,
      title: 'Add material',
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          final c = sheetContext.colors;
          final visible = options
              .where((m) => m.name.toLowerCase().contains(query))
              .toList();
          if (options.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: _materials.isEmpty
                  ? 'No materials yet'
                  : 'All materials added',
              message: _materials.isEmpty
                  ? 'Add materials under Stock first.'
                  : null,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (options.length > 6) ...[
                AppSearchField(
                  hint: 'Search materials',
                  onChanged: (v) =>
                      setSheet(() => query = v.trim().toLowerCase()),
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
                          child: Text(m.name,
                              style: AppTextStyles.bodyLarge
                                  .copyWith(color: c.ink)),
                        ),
                        Text(
                          '${CurrencyFormatter.format(m.unitCost)}/pc',
                          style:
                              AppTextStyles.bodySmall.copyWith(color: c.muted),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.add_circle_outline_rounded,
                            color: c.go, size: 22),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = getIt<ProductRepository>();
    final name = _name.text.trim();
    final alertLevel = int.tryParse(_alertLevel.text) ?? 0;
    final bomInputs = [
      for (final b in _bom)
        BomItemInput(
          materialId: b.materialId,
          quantityRequired: b.quantity,
          makes: b.makes,
        ),
    ];

    Result<void> outcome;
    if (_isNew) {
      final created = await repo.createProduct(
        name: name,
        sellPrice: _sellPrice,
        isStandalone: _isStandalone,
        initialQuantity:
            _isStandalone ? int.tryParse(_initialQty.text) ?? 0 : 0,
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        initialUnitCost:
            _isStandalone ? double.tryParse(_unitCost.text) ?? 0 : 0,
      );
      switch (created) {
        case Error(:final failure):
          outcome = Error(failure);
        case Success(value: final id):
          // createProduct has no alert level; set it right after.
          if (alertLevel > 0) {
            await repo.updateProduct(id: id, alertLevel: alertLevel);
          }
          outcome = _isStandalone || bomInputs.isEmpty
              ? const Success(null)
              : await repo.saveBomItems(id, bomInputs);
          if (outcome is Success && _photoDirty) {
            outcome = await getIt<SetProductPhoto>()(id, _photo);
          }
      }
    } else {
      final updated = await getIt<UpdateProduct>()(
        id: widget.productId!,
        name: name,
        description: _description.text,
        sellPrice: _sellPrice,
        unitCost: _isStandalone ? double.tryParse(_unitCost.text) ?? 0 : null,
        isStandalone: _isStandalone,
        alertLevel: alertLevel,
      );
      outcome = switch (updated) {
        Error() => updated,
        Success() => _isStandalone
            ? updated
            : await repo.saveBomItems(widget.productId!, bomInputs),
      };
      if (outcome is Success && _photoDirty) {
        outcome = await getIt<SetProductPhoto>()(widget.productId!, _photo);
      }
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

  @override
  Widget build(BuildContext context) {
    const back = BackButton();
    if (_loading) {
      return Scaffold(
          appBar: AppBar(leading: back),
          body: const Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
          appBar: AppBar(leading: back),
          body: Center(child: ErrorState(message: _error!, onRetry: _load)));
    }
    final c = context.colors;
    final money = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
    ];
    final digits = [FilteringTextInputFormatter.digitsOnly];

    return Scaffold(
      appBar: AppBar(
        leading: back,
        title: Text(_isNew ? 'New product' : 'Edit product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.page.copyWith(top: 8),
          children: [
            ListenableBuilder(
              listenable: _name,
              builder: (_, __) => ProductPhotoField(
                photo: _photo,
                name: _name.text,
                onChanged: (bytes) => setState(() {
                  _photo = bytes;
                  _photoDirty = true;
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              autofocus: _isNew,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: money,
              decoration: InputDecoration(
                  labelText: 'Sell price',
                  prefixText: '${CurrencyFormatter.symbol} '),
              validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                  ? 'Enter a price above 0'
                  : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                      value: false,
                      label: Text('Handmade'),
                      icon: Icon(Icons.content_cut_rounded, size: 18)),
                  ButtonSegment(
                      value: true,
                      label: Text('Resell'),
                      icon: Icon(Icons.inventory_2_outlined, size: 18)),
                ],
                selected: {_isStandalone},
                onSelectionChanged: _typeLockReason != null
                    ? null
                    : (s) => setState(() => _isStandalone = s.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
              child: Text(
                _typeLockReason ??
                    (_isStandalone
                        ? 'Bought ready-made. Tracks its own stock.'
                        : 'Made from materials. Stock comes from what you can build.'),
                style: AppTextStyles.bodySmall.copyWith(color: c.muted),
              ),
            ),
            if (_isStandalone)
              ..._buildResell(money, digits)
            else
              ..._buildHandmade(digits),
            const SizedBox(height: 12),
            ProductProfitCard(
                sellPrice: _sellPrice,
                cost: _cost,
                isStandalone: _isStandalone),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(children: [
        Expanded(
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving
                ? 'Saving…'
                : (_isNew ? 'Add product' : 'Save changes')),
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildHandmade(List<TextInputFormatter> digits) {
    final c = context.colors;
    return [
      SectionLabel(
        'Materials per piece',
        padding: const EdgeInsets.fromLTRB(2, 16, 0, 0),
        trailing: SectionAction(
            label: 'Add', icon: Icons.add_rounded, onTap: _addMaterial),
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
                  style: AppTextStyles.bodySmall
                      .copyWith(color: c.muted, fontSize: 13),
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
                  TextSpan(
                      text: '${CurrencyFormatter.format(b.unitCost)} each · '),
                  TextSpan(
                    text: CurrencyFormatter.format(b.lineCost),
                    style:
                        TextStyle(color: c.coin, fontWeight: FontWeight.w600),
                  ),
                ])),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _labelledStepper(
                      'Uses',
                      StepperInput(
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
                    const SizedBox(height: 6),
                    _labelledStepper(
                      'Makes',
                      StepperInput(
                        value: b.makes,
                        min: 1,
                        onChanged: (v) => setState(() => b.makes = v.toInt()),
                      ),
                    ),
                  ],
                ),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
          child: Text(
            'Uses is how many pieces of the material go in, Makes is how '
            'many of this product they make (1 sheet makes 9 cards). '
            'Set Uses to 0 to remove a material.',
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
        ),
      ],
      const SizedBox(height: 16),
      _alertField(digits),
    ];
  }

  Widget _labelledStepper(String label, Widget stepper) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style:
                AppTextStyles.bodySmall.copyWith(color: context.colors.muted)),
        const SizedBox(width: 8),
        stepper,
      ],
    );
  }

  /// One alert level for both types; only what it counts differs.
  Widget _alertField(List<TextInputFormatter> digits) {
    return TextFormField(
      controller: _alertLevel,
      keyboardType: TextInputType.number,
      inputFormatters: digits,
      decoration: InputDecoration(
        labelText: _isStandalone
            ? 'Reorder at (optional)'
            : 'Warn when I can make (optional)',
        helperText: _isStandalone
            ? 'Warn when stock drops to this.'
            : 'Warn when materials only cover this many.',
      ),
    );
  }

  List<Widget> _buildResell(
      List<TextInputFormatter> money, List<TextInputFormatter> digits) {
    final p = _product;
    return [
      const SectionLabel('Stock', padding: EdgeInsets.fromLTRB(2, 16, 2, 0)),
      const SizedBox(height: 8),
      if (!_isNew && p != null) ...[
        TextFormField(
          controller: _unitCost,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: money,
          decoration: InputDecoration(
            labelText: 'Cost per piece',
            prefixText: '${CurrencyFormatter.symbol} ',
            helperText: 'Receiving stock recalculates this as an average.',
          ),
        ),
        const SizedBox(height: 12),
      ] else ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _unitCost,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: money,
                decoration: InputDecoration(
                    labelText: 'Cost per piece',
                    prefixText: '${CurrencyFormatter.symbol} '),
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
      _alertField(digits),
    ];
  }
}

class _EditableBomItem {
  final int materialId;
  final String materialName;
  final double unitCost;
  int quantity;

  /// How many products [quantity] pieces make.
  int makes;

  _EditableBomItem({
    required this.materialId,
    required this.materialName,
    required this.unitCost,
    required this.quantity,
    this.makes = 1,
  });

  double get lineCost => quantity * unitCost / makes;
}
