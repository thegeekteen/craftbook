import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../discounts/domain/entities/discount_preset.dart';
import '../../../discounts/presentation/widgets/discount_sheet.dart';
import '../../domain/entities/order_discount.dart';
import '../../domain/entities/order_money.dart';

/// Discounts, tax and paid status for the order being made or edited.
///
/// Amounts are worked out here from the items total, so the card is right
/// even before (or without) a full preview.
class OrderTermsCard extends StatelessWidget {
  final double itemsTotal;
  final OrderTerms terms;

  /// The tax switching it on gives; null hides the tax switch.
  final OrderTax? availableTax;
  final String taxLabel;
  final List<DiscountPreset> presets;
  final ValueChanged<OrderDiscount> onAddDiscount;
  final ValueChanged<int> onRemoveDiscount;
  final ValueChanged<bool> onTaxChanged;
  final ValueChanged<bool> onPaidChanged;

  /// Opens the presets page; the card's owner reloads [presets] after.
  final VoidCallback? onManagePresets;

  const OrderTermsCard({
    super.key,
    required this.itemsTotal,
    required this.terms,
    required this.availableTax,
    required this.taxLabel,
    required this.presets,
    required this.onAddDiscount,
    required this.onRemoveDiscount,
    required this.onTaxChanged,
    required this.onPaidChanged,
    this.onManagePresets,
  });

  Future<void> _addCustom(BuildContext context) async {
    final discount = await showDiscountSheet(
      context,
      title: context.l10n.ordersAddDiscountTitle,
      actionLabel: context.l10n.commonAdd,
    );
    if (discount != null) onAddDiscount(discount);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = OrderMoney.compute(
      itemsTotal: itemsTotal,
      discounts: terms.discounts,
      tax: terms.tax,
    );
    final tax = terms.tax ?? availableTax;
    final rate = tax == null
        ? ''
        : tax.rate == tax.rate.roundToDouble()
            ? tax.rate.toStringAsFixed(0)
            : '${tax.rate}';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(context.l10n.ordersDiscountsCaps,
                    style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
              ),
              if (onManagePresets != null)
                TextButton(
                  onPressed: onManagePresets,
                  child: Text(context.l10n.ordersManage),
                ),
            ],
          ),
          for (final (i, d) in money.discounts.indexed)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${d.label} · ${discountValueLabel(d.kind, d.value)}',
                    style: AppTextStyles.bodyMedium.copyWith(color: c.ink),
                  ),
                ),
                Text(
                  '−${CurrencyFormatter.format(d.amount)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.go,
                    fontWeight: FontWeight.w600,
                    fontFeatures: AppTextStyles.tabular.fontFeatures,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.ordersRemoveDiscount(d.label),
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.close_rounded, size: 18, color: c.muted),
                  onPressed: () => onRemoveDiscount(i),
                ),
              ],
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in presets)
                AppChip(
                  label: '${p.label} −${discountValueLabel(p.kind, p.value)}',
                  selected: false,
                  onTap: () => onAddDiscount(p.toDiscount()),
                ),
              AppChip(
                label: presets.isEmpty
                    ? context.l10n.ordersAddDiscountChip
                    : context.l10n.ordersOtherDiscountChip,
                selected: false,
                onTap: () => _addCustom(context),
              ),
            ],
          ),
          // Room under the chips whichever rows follow.
          const SizedBox(height: 12),
          if (tax != null) ...[
            Divider(height: 1, color: c.hair),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: terms.tax != null,
              onChanged: onTaxChanged,
              title: Text(
                tax.inclusive
                    ? context.l10n.ordersTaxInPrices(taxLabel, rate)
                    : context.l10n.ordersTaxOnTop(taxLabel, rate),
                style: AppTextStyles.bodyMedium.copyWith(color: c.ink),
              ),
              subtitle: Text(
                terms.tax == null
                    ? context.l10n.ordersTaxOff
                    : tax.inclusive
                        ? context.l10n.ordersTaxPartOfTotal(
                            CurrencyFormatter.format(money.tax), taxLabel)
                        : context.l10n.ordersTaxCustomerPays(
                            CurrencyFormatter.format(money.tax)),
                style: AppTextStyles.bodySmall.copyWith(color: c.muted),
              ),
            ),
          ],
          Divider(height: 1, color: c.hair),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: terms.isPaid,
            onChanged: onPaidChanged,
            title: Text(context.l10n.ordersPaidSwitch,
                style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
            subtitle: Text(
              terms.isPaid
                  ? context.l10n.ordersPaidHasPaid
                  : context.l10n.ordersPaidWaitingFor(
                      CurrencyFormatter.format(money.customerPays)),
              style: AppTextStyles.bodySmall
                  .copyWith(color: terms.isPaid ? c.muted : c.warn),
            ),
          ),
        ],
      ),
    );
  }
}
