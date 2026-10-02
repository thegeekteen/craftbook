import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/currency_formatter.dart';

/// Currency text widget for displaying formatted prices
class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showSymbol;
  final bool compact;

  const CurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.showSymbol = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = compact
        ? CurrencyFormatter.formatCompact(amount)
        : CurrencyFormatter.format(amount);

    return Text(
      showSymbol ? formatted : formatted.replaceFirst('₱', ''),
      style: style ??
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpaceGrotesk',
            letterSpacing: -0.02,
          ),
    );
  }
}

/// Large currency display for profit/total amounts
class CurrencyDisplay extends StatelessWidget {
  final double amount;
  final String? label;
  final Color? color;

  const CurrencyDisplay({
    super.key,
    required this.amount,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              fontFamily: 'IBMPlexMono',
              letterSpacing: 0.1,
              color: AppColors.muted,
            ),
          ),
        const SizedBox(height: 4),
        CurrencyText(
          amount: amount,
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpaceGrotesk',
            letterSpacing: -0.02,
            color: color ?? AppColors.ink,
          ),
        ),
      ],
    );
  }
}
