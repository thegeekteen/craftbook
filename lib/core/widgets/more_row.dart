import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import 'app_card.dart';

/// A row on the More page: an icon tile, a title, what's there now, and a
/// chevron.
///
/// Extracted from the More page so the Debug section reads like the rest of the
/// list rather than like a guest that brought its own furniture.
class MoreRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const MoreRow({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CardRow(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Container(
        width: 36,
        height: 36,
        decoration:
            BoxDecoration(color: c.paper, borderRadius: AppRadii.controlAll),
        child: Icon(icon, size: 20, color: iconColor ?? c.ink),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: c.muted),
    );
  }
}
