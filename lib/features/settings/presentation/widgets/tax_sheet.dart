import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/tax_settings.dart';
import '../../../../core/utils/l10n_extension.dart';

/// Edits the shop's tax. Returns the new settings, or null when dismissed.
Future<TaxSettings?> showTaxSheet(
  BuildContext context, {
  required TaxSettings current,
}) {
  return showAppSheet<TaxSettings>(
    context: context,
    title: context.l10n.taxSheetTitle,
    subtitle: context.l10n.taxSheetSubtitle,
    builder: (_) => TaxForm(current: current),
  );
}

/// The body of [showTaxSheet]; public so it can be tested alone.
class TaxForm extends StatefulWidget {
  final TaxSettings current;

  const TaxForm({super.key, required this.current});

  @override
  State<TaxForm> createState() => _TaxFormState();
}

class _TaxFormState extends State<TaxForm> {
  late bool _enabled = widget.current.enabled;
  late bool _onByDefault = widget.current.onByDefault;
  late bool _inclusive = widget.current.inclusive;
  late final _rate = TextEditingController(text: _num(widget.current.rate));
  late final _label = TextEditingController(text: widget.current.label);

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';

  double get _rateValue => double.tryParse(_rate.text) ?? 0;

  @override
  void dispose() {
    _rate.dispose();
    _label.dispose();
    super.dispose();
  }

  void _save() {
    final label = _label.text.trim();
    Navigator.pop(
      context,
      TaxSettings(
        enabled: _enabled && _rateValue > 0,
        onByDefault: _onByDefault,
        rate: _rateValue.clamp(0, 100).toDouble(),
        inclusive: _inclusive,
        label: label.isEmpty ? TaxSettings.defaultLabel : label,
      ),
    );
  }

  /// One worked example, so "included" and "on top" mean something.
  String _example(AppLocalizations l10n) {
    final r = _rateValue / 100;
    final name = _label.text.trim().isEmpty
        ? TaxSettings.defaultLabel
        : _label.text.trim();
    if (_inclusive) {
      const price = 1120.0;
      final tax = price * r / (1 + r);
      return l10n.taxExampleIncluded(CurrencyFormatter.formatShort(price),
          CurrencyFormatter.format(tax), name);
    }
    const price = 1000.0;
    return l10n.taxExampleOnTop(
        CurrencyFormatter.formatShort(price),
        CurrencyFormatter.format(price * (1 + r)),
        CurrencyFormatter.format(price * r),
        name);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
          title: Text(context.l10n.taxUse,
              style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
          subtitle: Text(
              _enabled ? context.l10n.taxUseOnHint : context.l10n.taxUseOffHint,
              style: AppTextStyles.bodySmall.copyWith(color: c.muted)),
        ),
        if (_enabled)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _onByDefault,
            onChanged: (v) => setState(() => _onByDefault = v),
            title: Text(context.l10n.taxNewOrders,
                style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
            subtitle: Text(
                _onByDefault
                    ? context.l10n.taxNewOrdersOnHint
                    : context.l10n.taxNewOrdersOffHint,
                style: AppTextStyles.bodySmall.copyWith(color: c.muted)),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _label,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                    labelText: context.l10n.taxCalled, hintText: 'VAT'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _rate,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,3}\.?\d{0,2}'))
                ],
                decoration: InputDecoration(
                    labelText: context.l10n.taxRate, suffixText: '%'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(context.l10n.taxYourPrices,
            style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
        const SizedBox(height: 8),
        ChoiceChipRow<bool>.single(
          options: [
            ChipOption(true, context.l10n.taxIncluded),
            ChipOption(false, context.l10n.taxOnTop),
          ],
          selected: _inclusive,
          onSelected: (v) => setState(() => _inclusive = v),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration:
              BoxDecoration(color: c.paper, borderRadius: AppRadii.controlAll),
          child: Text(_example(context.l10n),
              style: AppTextStyles.bodySmall
                  .copyWith(color: c.muted, fontSize: 13)),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton(
              onPressed: _save, child: Text(context.l10n.commonSave)),
        ),
      ],
    );
  }
}
