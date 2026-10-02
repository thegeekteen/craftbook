import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../orders/domain/entities/order.dart';

/// Reusable order card widget for list displays
class OrderCard extends StatelessWidget {
  final Order order;
  final String? channelName;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.channelName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () => context.push(
                RouteNames.orderDetail.replaceFirst(':id', '${order.id}'),
              ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: order # + status
              Row(
                children: [
                  Text(
                    '#${order.id ?? '?'}',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const Spacer(),
                  StatusPill(
                    text: order.status.displayName,
                    type: _statusPillType,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Customer name
              Text(
                order.customerName,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),

              // Bottom row: ship-by date + channel + profit
              Row(
                children: [
                  // Ship-by date
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 13,
                    color: _isOverdue ? AppColors.alert : AppColors.muted,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    app_date.DateUtils.getRelativeDate(order.shipByDate),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _isOverdue ? AppColors.alert : AppColors.muted,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Channel pill
                  if (channelName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.coinSoft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        channelName!.toUpperCase(),
                        style: AppTextStyles.monoLabel.copyWith(
                          color: AppColors.coin,
                          fontSize: 8,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Profit
                  if (order.profit > 0)
                    CurrencyText(
                      amount: order.profit,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isOverdue {
    return order.status == OrderStatus.pending &&
        order.shipByDate.dateOnly.isBefore(DateTime.now().dateOnly);
  }

  StatusPillType get _statusPillType {
    switch (order.status) {
      case OrderStatus.pending:
        return _isOverdue ? StatusPillType.alert : StatusPillType.warning;
      case OrderStatus.packed:
        return StatusPillType.success;
      case OrderStatus.shipped:
        return StatusPillType.coin;
      case OrderStatus.cancelled:
        return StatusPillType.neutral;
    }
  }
}
