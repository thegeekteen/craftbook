import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_list_entry.dart';
import 'order_status_ui.dart';

/// The order card used by Today, Orders and the calendars.
///
/// Name and status, then the items, then id · when · channel and the
/// profit (always recomputed from components).
class OrderCard extends StatelessWidget {
  final OrderListEntry entry;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final order = entry.order;
    final profit = order.liveProfit;
    final (whenText, whenUrgent) = whenLabel(order);
    final muted = AppTextStyles.bodySmall.copyWith(color: c.muted);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(color: c.ink),
                ),
              ),
              const SizedBox(width: 8),
              OrderStatusPill.of(order),
            ],
          ),
          if (entry.lines.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              entry.itemSummary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: muted,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '#${order.id ?? '–'}',
                style: AppTextStyles.monoTag
                    .copyWith(color: c.muted, fontSize: 11),
              ),
              const SizedBox(width: 8),
              Text(
                whenText,
                maxLines: 1,
                style: muted.copyWith(
                  color: whenUrgent ? c.alert : c.muted,
                  fontWeight: whenUrgent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (entry.channelName != null) ...[
                const SizedBox(width: 8),
                Flexible(
                    child:
                        AppTag(entry.channelName!, type: AppTagType.outline)),
              ],
              const SizedBox(width: 8),
              const Spacer(),
              if (order.status != OrderStatus.cancelled)
                Text(
                  CurrencyFormatter.formatShort(profit),
                  style: AppTextStyles.amount.copyWith(
                    fontSize: 15.5,
                    color: profit >= 0 ? c.go : c.alert,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// The date that matters for the order's current status, and whether it
  /// needs attention.
  static (String, bool) whenLabel(Order order) {
    switch (order.status) {
      case OrderStatus.shipped:
        final at = order.shippedAt;
        return (
          at == null ? 'Shipped' : 'Shipped ${app_date.DateUtils.friendly(at)}',
          false
        );
      case OrderStatus.cancelled:
        return ('Cancelled', false);
      case OrderStatus.packed:
      case OrderStatus.pending:
        final days = app_date.DateUtils.daysFromToday(order.shipByDate);
        if (order.status == OrderStatus.pending && days < 0) {
          return (days == -1 ? 'Due yesterday' : 'Due ${-days} days ago', true);
        }
        if (days == 0)
          return ('Ships today', order.status == OrderStatus.pending);
        return (
          'Ships ${app_date.DateUtils.friendly(order.shipByDate)}',
          false
        );
    }
  }
}
