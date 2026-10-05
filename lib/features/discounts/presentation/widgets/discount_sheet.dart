import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../orders/domain/entities/order_discount.dart';
import '../../domain/usecases/discount_preset_usecases.dart';

/// Asks for a discount's name, kind and amount. Returns null when
/// dismissed.
Future<OrderDiscount?> showDiscountSheet(
  BuildContext context, {
  required String title,
  OrderDiscount? initial,
  String actionLabel = 'Save',
}) {
  return showAppSheet<OrderDiscount>(
    context: context,
    title: title,
    builder: (_) => DiscountForm(initial: initial, actionLabel: actionLabel),
  );
}

/// The body of [showDiscountSheet]; public so it can be tested alone.
class DiscountForm extends StatefulWidget {
  final OrderDiscount? initial;
  final String actionLabel;

  const DiscountForm({super.key, this.initial, this.actionLabel = 'Save'});

  @override
  State<DiscountForm> createState() => _DiscountFormState();
}

class _DiscountFormState extends State<DiscountForm> {
  late final _label = TextEditingController(text: widget.initial?.label);
  late final _value = TextEditingController(text: _num(widget.initial?.value));
  late DiscountKind _kind = widget.initial?.kind ?? DiscountKind.percent;
  String? _error;

  static String _num(double? v) {
    if (v == null || v == 0) return '';
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';
  }

  @override
  void dispose() {
    _label.dispose();
    _value.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_value.text) ?? 0;
    final invalid =
        validateDiscount(label: _label.text, kind: _kind, value: value);
    if (invalid != null) {
      setState(() => _error = invalid.message);
      return;
    }
    Navigator.pop(
      context,
      OrderDiscount(label: _label.text.trim(), kind: _kind, value: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final percent = _kind == DiscountKind.percent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _label,
          autofocus: widget.initial == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
              labelText: 'Name', hintText: 'e.g. Loyal customer'),
        ),
        const SizedBox(height: 12),
        ChoiceChipRow<DiscountKind>.single(
          options: const [
            ChipOption(DiscountKind.percent, 'Percent'),
            ChipOption(DiscountKind.fixed, 'Fixed amount'),
          ],
          selected: _kind,
          onSelected: (k) => setState(() => _kind = k),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
          ],
          decoration: InputDecoration(
            labelText: percent ? 'Percent off' : 'Amount off',
            prefixText: percent ? null : '${CurrencyFormatter.symbol} ',
            suffixText: percent ? '%' : null,
            helperText: percent
                ? 'Taken off the items total'
                : 'Taken off the order once',
          ),
          onSubmitted: (_) => _save(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!,
              style: AppTextStyles.bodySmall.copyWith(color: c.alert)),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton(
            onPressed: _save,
            child: Text(widget.actionLabel),
          ),
        ),
      ],
    );
  }
}
