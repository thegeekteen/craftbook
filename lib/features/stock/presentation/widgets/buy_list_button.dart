import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';

/// App-bar shortcut to the buy list, red with a count when something is
/// low. Sits on the Inventory page beside the Filter button; it carries no
/// outer padding so the caller decides the spacing.
class BuyListButton extends StatelessWidget {
  final int lowCount;
  final VoidCallback onPressed;

  const BuyListButton(
      {super.key, required this.lowCount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: AppTextStyles.bodySmall
            .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      icon: Icon(Icons.shopping_basket_outlined,
          size: 17, color: lowCount > 0 ? c.alert : c.muted),
      label: Text(lowCount > 0 ? 'Buy list · $lowCount' : 'Buy list'),
    );
  }
}
