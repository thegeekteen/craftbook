import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_setting.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/utils/l10n_extension.dart';

/// Picks the shop's currency. Returns null when dismissed.
Future<CurrencySetting?> showCurrencySheet(
  BuildContext context, {
  required CurrencySetting current,
}) {
  return showAppSheet<CurrencySetting>(
    context: context,
    title: context.l10n.currencySheetTitle,
    subtitle: context.l10n.currencySheetSubtitle,
    builder: (_) => CurrencyPicker(current: current),
  );
}

/// The body of [showCurrencySheet]; public so it can be tested alone.
class CurrencyPicker extends StatefulWidget {
  final CurrencySetting current;

  const CurrencyPicker({super.key, required this.current});

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  late final _symbol = TextEditingController(
      text: widget.current.isCustom ? widget.current.symbol : '');
  late bool _wholeNumbers =
      widget.current.isCustom && widget.current.decimals == 0;

  @override
  void dispose() {
    _symbol.dispose();
    super.dispose();
  }

  void _saveCustom() {
    final symbol = _symbol.text.trim();
    if (symbol.isEmpty) return;
    Navigator.pop(
      context,
      CurrencySetting(
        code: CurrencySetting.customCode,
        symbol: symbol,
        decimals: _wholeNumbers ? 0 : 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final p in CurrencySetting.presets)
          InkWell(
            borderRadius: AppRadii.controlAll,
            onTap: () => Navigator.pop(context, p),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(p.symbol,
                        style: AppTextStyles.bodyLarge.copyWith(
                            color: c.ink, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text(p.name,
                        style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
                  ),
                  Text(p.code,
                      style: AppTextStyles.monoTag.copyWith(color: c.muted)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    child: p == widget.current
                        ? Icon(Icons.check_rounded, size: 20, color: c.go)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text(context.l10n.currencySomethingElse,
            style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _symbol,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: context.l10n.currencySymbol,
                  hintText: context.l10n.currencySymbolHint,
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _saveCustom(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _symbol.text.trim().isEmpty ? null : _saveCustom,
              child: Text(context.l10n.currencyUse),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _wholeNumbers,
          onChanged: (v) => setState(() => _wholeNumbers = v),
          title: Text(context.l10n.currencyNoCents,
              style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
          subtitle: Text(context.l10n.currencyNoCentsHint,
              style: AppTextStyles.bodySmall.copyWith(color: c.muted)),
        ),
      ],
    );
  }
}
