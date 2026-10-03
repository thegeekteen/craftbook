import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../domain/entities/material.dart';
import '../../domain/usecases/get_material_detail.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';

/// Receive packs of a material, with a live preview of the new count and
/// weighted-average unit cost.
class ReceiveStockPage extends StatefulWidget {
  final int materialId;

  const ReceiveStockPage({super.key, required this.materialId});

  @override
  State<ReceiveStockPage> createState() => _ReceiveStockPageState();
}

class _ReceiveStockPageState extends State<ReceiveStockPage> {
  Material? _material;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  int _packs = 1;
  final _price = TextEditingController();
  final _supplier = TextEditingController();

  @override
  void initState() {
    super.initState();
    _price.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _price.dispose();
    _supplier.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await getIt<GetMaterialDetail>()(widget.materialId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Error(:final failure):
          _error = failure.message;
        case Success(value: final detail):
          _material = detail.material;
          // Last price paid is the usual starting point.
          if (detail.material.packPrice > 0) {
            _price.text = detail.material.packPrice.toStringAsFixed(2);
          }
          _supplier.text = detail.material.supplier ?? '';
      }
    });
  }

  double get _pricePerPack => double.tryParse(_price.text) ?? 0;
  int get _pieces => _packs * (_material?.packSize ?? 0);

  /// new = (oldQty × oldCost + newQty × newPrice) / (oldQty + newQty)
  double get _newUnitCost {
    final m = _material!;
    final newPrice = m.packSize > 0 ? _pricePerPack / m.packSize : 0.0;
    final total = m.quantityOnHand + _pieces;
    if (total == 0) return newPrice;
    return (m.quantityOnHand * m.unitCost + _pieces * newPrice) / total;
  }

  void _submit() {
    if (_pricePerPack <= 0) {
      context.showSnackBar('Enter what you paid per pack', isError: true);
      return;
    }
    setState(() => _saving = true);
    context.read<MaterialsBloc>().add(ReceiveStockEvent(
          materialId: widget.materialId,
          packsReceived: _packs,
          pricePerPack: _pricePerPack,
          supplier: _supplier.text.trim().isEmpty ? null : _supplier.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    if (_material == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: ErrorState(message: _error ?? 'Material not found', onRetry: _load)),
      );
    }

    final c = context.colors;
    final m = _material!;
    final costUp = _newUnitCost > m.unitCost + 0.005;

    return BlocListener<MaterialsBloc, MaterialsState>(
      listener: (context, state) {
        if (state is StockReceived) {
          context.showSnackBar('Added $_pieces pcs of ${m.name}');
          context.pop(true);
        }
        if (state is MaterialsError) {
          setState(() => _saving = false);
          context.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('RECEIVE', style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
              Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PACKS RECEIVED', style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
                            const SizedBox(height: 2),
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(text: '${m.packSize} pcs per pack · '),
                                TextSpan(
                                  text: '+$_pieces pcs',
                                  style: TextStyle(color: c.go, fontWeight: FontWeight.w600),
                                ),
                              ]),
                              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                            ),
                          ],
                        ),
                      ),
                      StepperInput(
                        value: _packs,
                        min: 1,
                        max: 999,
                        onChanged: (v) => setState(() => _packs = v.toInt()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    decoration: const InputDecoration(labelText: 'Price per pack', prefixText: '₱ '),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _supplier,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Supplier (optional)'),
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
                      Text('${m.quantityOnHand}', style: AppTextStyles.amount.copyWith(color: c.muted, fontSize: 20)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward_rounded, size: 18, color: c.muted),
                      ),
                      Text(
                        '${m.quantityOnHand + _pieces}',
                        style: AppTextStyles.displayMedium.copyWith(color: c.go, fontSize: 32),
                      ),
                      const SizedBox(width: 6),
                      Text('PCS', style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PipStrip(
                    total: m.quantityOnHand + _pieces,
                    free: m.quantityFree,
                    promised: m.quantityPromised,
                    incoming: _pieces,
                    alertLevel: m.alertLevel,
                  ),
                  const SizedBox(height: 12),
                  Divider(color: c.hair),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Unit cost (weighted)', style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
                      ),
                      Text(
                        '${CurrencyFormatter.format(m.unitCost)} → ',
                        style: AppTextStyles.bodyMedium.copyWith(color: c.muted),
                      ),
                      Text(
                        CurrencyFormatter.format(_newUnitCost),
                        style: AppTextStyles.amount.copyWith(color: costUp ? c.alert : c.coin, fontSize: 16),
                      ),
                    ],
                  ),
                  if (costUp)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Products using this will cost a bit more to make.',
                        style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                      ),
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
              label: Text('Add $_pieces pcs to stock'),
            ),
          ),
        ]),
      ),
    );
  }
}
