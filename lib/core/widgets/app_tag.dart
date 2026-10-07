import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/text_styles.dart';
import '../utils/l10n_extension.dart';

enum AppTagType {
  /// Grey, for passive facts (Inactive, Resell).
  neutral,

  /// Red, for low stock and blockers.
  low,

  /// Green, for positive confirmations (Added).
  ok,

  /// Amber, for things that need attention soon.
  warn,

  /// Outlined, for channel names.
  outline,
}

/// Small square-cornered tag. The single implementation of LOW, ADDED,
/// INACTIVE, channel names and similar labels.
class AppTag extends StatelessWidget {
  final String? text;
  final AppTagType type;

  const AppTag(String this.text, {super.key, this.type = AppTagType.neutral});

  const AppTag.low({super.key, this.text}) : type = AppTagType.low;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = this.text ?? context.l10n.commonLow;
    final (Color bg, Color fg, Color? border) = switch (type) {
      AppTagType.neutral => (c.hair, c.muted, null),
      AppTagType.low => (c.alertSoft, c.alert, null),
      AppTagType.ok => (c.goSoft, c.go, null),
      AppTagType.warn => (c.warnSoft, c.warn, null),
      AppTagType.outline => (Colors.transparent, c.ink, c.hair),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.tagAll,
        border: border != null ? Border.all(color: border) : null,
      ),
      // Channel names keep their own casing in the body face; status-like
      // tags use the uppercase mono label.
      child: Text(
        type == AppTagType.outline ? text : text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: type == AppTagType.outline
            ? AppTextStyles.bodySmall.copyWith(
                color: fg,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.15)
            : AppTextStyles.monoTag.copyWith(color: fg),
      ),
    );
  }
}
