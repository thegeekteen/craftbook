import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/text_styles.dart';

/// Rounded status badge with a leading dot.
class StatusPill extends StatelessWidget {
  final String text;
  final StatusPillType type;

  const StatusPill({
    super.key,
    required this.text,
    this.type = StatusPillType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg) = switch (type) {
      StatusPillType.success => (c.goSoft, c.go),
      StatusPillType.alert => (c.alertSoft, c.alert),
      StatusPillType.warning => (c.warnSoft, c.warn),
      StatusPillType.coin => (c.coinSoft, c.coin),
      StatusPillType.ink => (c.ink, c.paper),
      StatusPillType.neutral => (c.hair, c.muted),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 3.5, 9, 3.5),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.pillAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            text.toUpperCase(),
            style: AppTextStyles.monoTag.copyWith(color: fg, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

enum StatusPillType {
  neutral,
  success,
  alert,
  warning,
  coin,
  ink,
}
