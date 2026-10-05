import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../settings/domain/entities/order_amount_shown.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_list_entry.dart';
import 'order_status_ui.dart';

/// Compact order row for calendars: name, "#id · 3 items · ₱412", pill.
///
/// The amount is the order total, or "₱310 profit" when [amountShown] asks
/// for profit.
class OrderMiniRow extends StatelessWidget {
  final OrderListEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final OrderAmountShown amountShown;

  const OrderMiniRow({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
    this.amountShown = OrderAmountShown.total,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final o = entry.order;
    final pieces = entry.pieceCount;
    final parts = [
      '#${o.id ?? '–'}',
      if (pieces > 0)
        '${QuantityFormatter.format(pieces)} ${pieces == 1 ? 'item' : 'items'}',
      if (o.status != OrderStatus.cancelled)
        amountShown == OrderAmountShown.profit
            ? '${CurrencyFormatter.formatShort(o.liveProfit)} profit'
            : CurrencyFormatter.formatShort(o.liveTotal),
    ];
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.hair),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: c.ink, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      parts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: c.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OrderStatusPill.of(o),
            ],
          ),
        ),
      ),
    );
  }
}
