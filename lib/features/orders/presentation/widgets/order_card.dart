import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../settings/domain/entities/order_amount_shown.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_list_entry.dart';
import 'order_l10n.dart';
import 'order_status_ui.dart';

/// The order card used by Today and Orders.
///
/// Name and status, then the items, then id · when · channel and the
/// amount: the order total, or the profit (always recomputed from
/// components) when [amountShown] asks for it.
class OrderCard extends StatelessWidget {
  final OrderListEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final OrderAmountShown amountShown;

  const OrderCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
    this.amountShown = OrderAmountShown.total,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final order = entry.order;
    final showProfit = amountShown == OrderAmountShown.profit;
    final amount = showProfit ? order.liveProfit : order.liveTotal;
    final draft = order.isDraft;
    final (whenText, whenUrgent) =
        draft ? (draftNeeds(context, entry), false) : whenLabel(context, order);
    final muted = AppTextStyles.bodySmall.copyWith(color: c.muted);
    final unnamed = order.customerName.trim().isEmpty;

    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      // A draft sits on the page rather than on a card: it isn't an order yet.
      color: draft ? c.paper : null,
      borderColor: draft ? c.muted : null,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  unnamed
                      ? context.l10n.ordersDraftNoCustomer
                      : order.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: unnamed ? c.muted : c.ink,
                    fontStyle: unnamed ? FontStyle.italic : null,
                  ),
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
              // The left side shrinks (tag first) so the amount always sits
              // on the right edge.
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '#${order.id ?? '–'}',
                      style: AppTextStyles.monoTag
                          .copyWith(color: c.muted, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        whenText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: muted.copyWith(
                          color: whenUrgent ? c.alert : c.muted,
                          fontWeight:
                              whenUrgent ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (entry.channelName != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                          child: AppTag(entry.channelName!,
                              type: AppTagType.outline)),
                    ],
                    if (order.isAwaitingPayment) ...[
                      const SizedBox(width: 6),
                      Flexible(
                          child: AppTag(context.l10n.ordersUnpaidTag,
                              type: AppTagType.warn)),
                    ],
                  ],
                ),
              ),
              if (order.status != OrderStatus.cancelled &&
                  !(draft && entry.lines.isEmpty)) ...[
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.formatShort(amount),
                  style: AppTextStyles.amount.copyWith(
                    fontSize: 15.5,
                    color: !showProfit
                        ? c.ink
                        : amount >= 0
                            ? c.go
                            : c.alert,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// The date that matters for the order's current status, and whether it
  /// needs attention.
  static (String, bool) whenLabel(BuildContext context, Order order) {
    final l10n = context.l10n;
    switch (order.status) {
      case OrderStatus.draft:
        return (l10n.ordersStatusDraft, false);
      case OrderStatus.shipped:
        final at = order.shippedAt;
        return (
          at == null
              ? l10n.ordersWhenShipped
              : l10n.ordersWhenShippedOn(friendlyDate(context, at)),
          false
        );
      case OrderStatus.cancelled:
        return (l10n.ordersWhenCancelled, false);
      case OrderStatus.packed:
      case OrderStatus.pending:
        final days = app_date.DateUtils.daysFromToday(order.shipByDate);
        if (order.status == OrderStatus.pending && days < 0) {
          return (
            days == -1
                ? l10n.ordersWhenDueYesterday
                : l10n.ordersWhenDueDaysAgo(-days),
            true
          );
        }
        if (days == 0) {
          return (
            l10n.ordersWhenShipsToday,
            order.status == OrderStatus.pending
          );
        }
        return (
          l10n.ordersWhenShips(friendlyDate(context, order.shipByDate)),
          false
        );
    }
  }

  /// What a draft still lacks before it can be placed, or that it's ready.
  static String draftNeeds(BuildContext context, OrderListEntry entry) {
    final l10n = context.l10n;
    final order = entry.order;
    final missing = [
      if (order.customerName.trim().isEmpty) l10n.ordersDraftNeedCustomer,
      if (order.channelId == null) l10n.ordersDraftNeedChannel,
      if (entry.lines.isEmpty) l10n.ordersDraftNeedItems,
    ];
    return missing.isEmpty
        ? l10n.ordersDraftReady
        : l10n.ordersDraftNeeds(missing.join(', '));
  }
}
