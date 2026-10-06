import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/error/result.dart';
import '../../../units/domain/entities/unit_of_measure.dart';
import '../../../units/domain/usecases/unit_usecases.dart';
import '../../../units/presentation/widgets/unit_picker_field.dart';
import '../../domain/repositories/material_repository.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';

/// Add or edit a material: what it is, how it's sold, when to reorder.
/// Pass [materialId] to edit; stock counts are changed by receiving or
/// counting, never here.
class NewMaterialPage extends StatelessWidget {
  final int? materialId;

  const NewMaterialPage({super.key, this.materialId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MaterialsBloc>(),
      child: _NewMaterialView(materialId: materialId),
    );
  }
}

class _NewMaterialView extends StatefulWidget {
  final int? materialId;

  const _NewMaterialView({this.materialId});

  @override
  State<_NewMaterialView> createState() => _NewMaterialViewState();
}

class _NewMaterialViewState extends State<_NewMaterialView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _packSize = TextEditingController();
  final _packPrice = TextEditingController();
  final _alertLevel = TextEditingController(text: '10');
  final _initialQty = TextEditingController(text: '0');
  final _supplier = TextEditingController();
  bool _saving = false;
  bool _loading = false;
  String? _loadError;

  /// What this material is counted in. Labels the quantity fields below, so it
  /// loads before the form shows.
  UnitOfMeasure? _unit;

  bool get _isEditing => widget.materialId != null;

  /// The unit's label, or nothing until it loads.
  String get _unitLabel => _unit?.label ?? '';

  @override
  void initState() {
    super.initState();
    _loading = true;
    if (_isEditing) {
      _loadMaterial();
    } else {
      _loadDefaultUnit();
    }
    for (final ctrl in [_packSize, _packPrice]) {
      ctrl.addListener(() => setState(() {}));
    }
  }

  Future<void> _loadDefaultUnit() async {
    final result = await getIt<GetDefaultUnit>()();
    if (!mounted) return;
    setState(() {
      _unit = switch (result) {
        Success(:final value) => value,
        Error() => null,
      };
      _loading = false;
    });
  }

  Future<void> _loadMaterial() async {
    final result =
        await getIt<MaterialRepository>().getMaterialById(widget.materialId!);
    if (!mounted) return;
    switch (result) {
      case Error(:final failure):
        setState(() {
          _loadError = failure.message;
          _loading = false;
        });
      case Success(value: null):
        setState(() {
          _loadError = 'Material not found';
          _loading = false;
        });
      case Success(:final value?):
        _name.text = value.name;
        _packSize.text = '${value.packSize}';
        _packPrice.text = value.packPrice.toStringAsFixed(2);
        _alertLevel.text = '${value.alertLevel}';
        _supplier.text = value.supplier ?? '';
        setState(() {
          _unit = UnitOfMeasure(id: value.unitId, label: value.unit);
          _loading = false;
        });
    }
  }

  @override
  void dispose() {
    for (final ctrl in [
      _name,
      _packSize,
      _packPrice,
      _alertLevel,
      _initialQty,
      _supplier
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  double? get _unitCost {
    final size = double.tryParse(_packSize.text);
    final price = double.tryParse(_packPrice.text);
    if (size == null || size <= 0 || price == null) return null;
    return price / size;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final supplier =
        _supplier.text.trim().isEmpty ? null : _supplier.text.trim();
    final bloc = context.read<MaterialsBloc>();
    if (_isEditing) {
      bloc.add(UpdateMaterialEvent(
        id: widget.materialId!,
        name: _name.text.trim(),
        unitId: _unit?.id,
        packSize: double.parse(_packSize.text),
        packPrice: double.parse(_packPrice.text),
        alertLevel: double.tryParse(_alertLevel.text) ?? 0,
        supplier: supplier,
      ));
      return;
    }
    bloc.add(CreateMaterialEvent(
      name: _name.text.trim(),
      unitId: _unit?.id,
      packSize: double.parse(_packSize.text),
      packPrice: double.parse(_packPrice.text),
      alertLevel: double.tryParse(_alertLevel.text) ?? 0,
      initialQuantity: double.tryParse(_initialQty.text) ?? 0,
      supplier: supplier,
    ));
  }

  String? _positiveNumber(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null || n <= 0) return 'Enter a number above 0';
    return null;
  }

  String? _nonNegativeNumber(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null || n < 0) return 'Enter 0 or more';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Counts can be fractional (1.25 boards a head), so allow a dot.
    final counts = [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))];
    final money = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
    ];

    return BlocListener<MaterialsBloc, MaterialsState>(
      listener: (context, state) {
        if (state is MaterialCreated) {
          context.showSnackBar('${_name.text.trim()} added');
          context.pop(true);
        }
        if (state is MaterialUpdated) {
          context.showSnackBar('${_name.text.trim()} updated');
          context.pop(true);
        }
        if (state is MaterialsError) {
          setState(() => _saving = false);
          context.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        appBar:
            AppBar(title: Text(_isEditing ? 'Edit material' : 'New material')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Text(_loadError!,
                        style:
                            AppTextStyles.bodySmall.copyWith(color: c.alert)))
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: AppSpacing.page.copyWith(top: 8),
                      children: [
                        TextFormField(
                          controller: _name,
                          autofocus: !_isEditing,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'e.g. Glass seed beads 2mm',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter a name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        UnitPickerField(
                          label: 'Counted in',
                          unit: _unit,
                          onChanged: (u) => setState(() => _unit = u),
                        ),
                        const SectionLabel('How you buy it'),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _packSize,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: counts,
                                decoration: InputDecoration(
                                    labelText: _unitLabel.isEmpty
                                        ? 'Per pack'
                                        : '$_unitLabel per pack'),
                                validator: _positiveNumber,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _packPrice,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: money,
                                decoration: InputDecoration(
                                    labelText: 'Pack price',
                                    prefixText: '${CurrencyFormatter.symbol} '),
                                validator: (v) {
                                  final n = double.tryParse(v ?? '');
                                  return (n == null || n < 0)
                                      ? 'Enter a price'
                                      : null;
                                },
                              ),
                            ),
                          ],
                        ),
                        if (_unitCost != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                            child: Text(
                              '${CurrencyFormatter.format(_unitCost!)}'
                              '${_unitLabel.isEmpty ? '' : ' per $_unitLabel'}',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: c.coin, fontWeight: FontWeight.w600),
                            ),
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _supplier,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                              labelText: 'Supplier (optional)'),
                        ),
                        const SectionLabel('Stock'),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isEditing) ...[
                              Expanded(
                                child: TextFormField(
                                  controller: _initialQty,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: counts,
                                  decoration: InputDecoration(
                                      labelText: _unitLabel.isEmpty
                                          ? 'On hand now'
                                          : '$_unitLabel on hand now'),
                                  validator: _nonNegativeNumber,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: TextFormField(
                                controller: _alertLevel,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: counts,
                                decoration: const InputDecoration(
                                    labelText: 'Reorder at'),
                                validator: _nonNegativeNumber,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                          child: Text(
                            "You'll see a warning and it goes on the buy list when stock drops to the reorder level.",
                            style: AppTextStyles.bodySmall
                                .copyWith(color: c.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
        bottomNavigationBar: BottomActionBar(children: [
          Expanded(
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving
                  ? 'Saving…'
                  : (_isEditing ? 'Save changes' : 'Add material')),
            ),
          ),
        ]),
      ),
    );
  }
}
