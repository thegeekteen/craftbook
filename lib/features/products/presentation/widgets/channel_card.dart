import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/channel.dart';

/// A sales channel: its fee recipe, an example of what you keep, and an
/// on/off switch for new orders.
class ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onActiveChanged;

  /// Sale amount used for the "you keep" example.
  static const double exampleSale = 500;

  const ChannelCard({
    super.key,
    required this.channel,
    this.onTap,
    this.onLongPress,
    this.onActiveChanged,
  });

  static String _pct(double v) => v == v.roundToDouble()
      ? '${v.toStringAsFixed(0)}%'
      : '${v.toStringAsFixed(1)}%';

  /// "8% + 2% + ₱5 · you pay ₱130 shipping"
  static String recipe(Channel ch, AppLocalizations l10n) {
    final parts = <String>[
      if (ch.commissionRate > 0) _pct(ch.commissionRate),
      if (ch.transactionFeeRate > 0) _pct(ch.transactionFeeRate),
      if (ch.flatFee > 0) CurrencyFormatter.formatShort(ch.flatFee),
    ];
    final fees = parts.isEmpty ? l10n.productsChannelNoFees : parts.join(' + ');
    return ch.shippingPaidByUs > 0
        ? l10n.productsChannelRecipeShipping(
            fees, CurrencyFormatter.formatShort(ch.shippingPaidByUs))
        : fees;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final ch = channel;
    final fees = ch.calculateFees(exampleSale);
    final keep = exampleSale - fees - ch.shippingPaidByUs;
    final effective = fees / exampleSale * 100;

    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 14),
      child: Opacity(
        opacity: ch.isActive ? 1 : 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(ch.name,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: c.ink, fontSize: 16)),
                ),
                Text(
                  ch.isActive ? l10n.commonOn : l10n.commonOff,
                  style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                ),
                Switch(value: ch.isActive, onChanged: onActiveChanged),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(recipe(ch, l10n),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: c.muted, fontSize: 13)),
                  ),
                  Text(
                    '~${_pct(effective)}',
                    style: AppTextStyles.amount
                        .copyWith(color: c.warn, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                    text:
                        '${ch.isActive ? l10n.productsChannelYouKeep(CurrencyFormatter.formatShort(exampleSale)) : l10n.productsChannelHiddenKeep(CurrencyFormatter.formatShort(exampleSale))} '),
                TextSpan(
                  text: CurrencyFormatter.format(keep),
                  style: TextStyle(color: c.ink, fontWeight: FontWeight.w600),
                ),
              ]),
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ],
        ),
      ),
    );
  }
}
