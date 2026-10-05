import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../utils/currency_formatter.dart';

/// Formatted peso amount (₱1,234.56) in the display face with tabular
/// figures.
class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showSymbol;
  final bool compact;

  /// Drop ".00" on whole amounts.
  final bool short;

  /// Prefix positive amounts with "+".
  final bool signed;

  const CurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.showSymbol = true,
    this.compact = false,
    this.short = false,
    this.signed = false,
  });

  @override
  Widget build(BuildContext context) {
    final abs = amount.abs();
    var formatted = compact
        ? CurrencyFormatter.formatCompact(abs)
        : short
            ? CurrencyFormatter.formatShort(abs)
            : CurrencyFormatter.format(abs);
    if (!showSymbol) {
      formatted = formatted.replaceFirst(CurrencyFormatter.symbol, '');
    }
    final sign = amount < 0 ? '−' : (signed && amount > 0 ? '+' : '');

    return Text(
      '$sign$formatted',
      maxLines: 1,
      style: style ?? AppTextStyles.amount.copyWith(color: context.colors.ink),
    );
  }
}
