import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
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
      title: 'Add a discount',
      actionLabel: 'Add',
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
                child: Text('DISCOUNTS',
                    style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
              ),
              if (onManagePresets != null)
                TextButton(
                  onPressed: onManagePresets,
                  child: const Text('Manage'),
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
                  tooltip: 'Remove ${d.label}',
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
                label: presets.isEmpty ? '+ Add discount' : '+ Other',
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
                '$taxLabel $rate% · ${tax.inclusive ? 'in prices' : 'added on top'}',
                style: AppTextStyles.bodyMedium.copyWith(color: c.ink),
              ),
              subtitle: Text(
                terms.tax == null
                    ? 'Off for this order'
                    : tax.inclusive
                        ? '${CurrencyFormatter.format(money.tax)} of the total is $taxLabel'
                        : 'Customer pays ${CurrencyFormatter.format(money.tax)} more',
                style: AppTextStyles.bodySmall.copyWith(color: c.muted),
              ),
            ),
          ],
          Divider(height: 1, color: c.hair),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: terms.isPaid,
            onChanged: onPaidChanged,
            title: Text('Paid',
                style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
            subtitle: Text(
              terms.isPaid
                  ? 'The customer has paid'
                  : 'Waiting for ${CurrencyFormatter.format(money.customerPays)}',
              style: AppTextStyles.bodySmall
                  .copyWith(color: terms.isPaid ? c.muted : c.warn),
            ),
          ),
        ],
      ),
    );
  }
}
