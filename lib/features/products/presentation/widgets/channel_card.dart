import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/channel.dart';

/// Channel card widget for channel management
class ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback? onTap;

  const ChannelCard({
    super.key,
    required this.channel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalFeeRate = channel.commissionRate + channel.transactionFeeRate;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: name + active pill
              Row(
                children: [
                  Expanded(
                    child: Text(
                      channel.name,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.ink),
                    ),
                  ),
                  StatusPill(
                    text: channel.isActive ? 'ACTIVE' : 'INACTIVE',
                    type: channel.isActive
                        ? StatusPillType.success
                        : StatusPillType.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Total fee %
              Text(
                'Total fees: ${totalFeeRate.toStringAsFixed(1)}%',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.warning),
              ),
              const SizedBox(height: 8),

              // Fee breakdown
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _FeeRow(
                        label: 'Commission',
                        value: '${channel.commissionRate.toStringAsFixed(1)}%'),
                    _FeeRow(
                        label: 'Transaction fee',
                        value:
                            '${channel.transactionFeeRate.toStringAsFixed(1)}%'),
                    _FeeRow(
                        label: 'Flat fee',
                        value: channel.flatFee.currency),
                    _FeeRow(
                        label: 'Shipping (us)',
                        value: channel.shippingPaidByUs.currency),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;

  const _FeeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.ink)),
        ],
      ),
    );
  }
}
