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
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';

/// Add a material: what it is, how it's sold, when to reorder.
class NewMaterialPage extends StatelessWidget {
  const NewMaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MaterialsBloc>(),
      child: const _NewMaterialView(),
    );
  }
}

class _NewMaterialView extends StatefulWidget {
  const _NewMaterialView();

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

  @override
  void initState() {
    super.initState();
    for (final ctrl in [_packSize, _packPrice]) {
      ctrl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final ctrl in [_name, _packSize, _packPrice, _alertLevel, _initialQty, _supplier]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  double? get _unitCost {
    final size = int.tryParse(_packSize.text);
    final price = double.tryParse(_packPrice.text);
    if (size == null || size <= 0 || price == null) return null;
    return price / size;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    context.read<MaterialsBloc>().add(CreateMaterialEvent(
          name: _name.text.trim(),
          packSize: int.parse(_packSize.text),
          packPrice: double.parse(_packPrice.text),
          alertLevel: int.tryParse(_alertLevel.text) ?? 0,
          initialQuantity: int.tryParse(_initialQty.text) ?? 0,
          supplier: _supplier.text.trim().isEmpty ? null : _supplier.text.trim(),
        ));
  }

  String? _positiveInt(String? v) {
    final n = int.tryParse(v ?? '');
    if (n == null || n <= 0) return 'Enter a whole number above 0';
    return null;
  }

  String? _nonNegativeInt(String? v) {
    final n = int.tryParse(v ?? '');
    if (n == null || n < 0) return 'Enter 0 or more';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final digits = [FilteringTextInputFormatter.digitsOnly];
    final money = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))];

    return BlocListener<MaterialsBloc, MaterialsState>(
      listener: (context, state) {
        if (state is MaterialCreated) {
          context.showSnackBar('${_name.text.trim()} added');
          context.pop(true);
        }
        if (state is MaterialsError) {
          setState(() => _saving = false);
          context.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('New material')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.page.copyWith(top: 8),
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Glass seed beads 2mm',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SectionLabel('How you buy it'),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _packSize,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits,
                      decoration: const InputDecoration(labelText: 'Pieces per pack'),
                      validator: _positiveInt,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _packPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: money,
                      decoration: const InputDecoration(labelText: 'Pack price', prefixText: '₱ '),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n < 0) ? 'Enter a price' : null;
                      },
                    ),
                  ),
                ],
              ),
              if (_unitCost != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                  child: Text(
                    '${CurrencyFormatter.format(_unitCost!)} per piece',
                    style: AppTextStyles.bodySmall.copyWith(color: c.coin, fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _supplier,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Supplier (optional)'),
              ),
              const SectionLabel('Stock'),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _initialQty,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits,
                      decoration: const InputDecoration(labelText: 'Pieces on hand now'),
                      validator: _nonNegativeInt,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _alertLevel,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits,
                      decoration: const InputDecoration(labelText: 'Reorder at'),
                      validator: _nonNegativeInt,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Text(
                  "You'll see a warning and it goes on the buy list when stock drops to the reorder level.",
                  style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomActionBar(children: [
          Expanded(
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Add material'),
            ),
          ),
        ]),
      ),
    );
  }
}
