import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

enum BannerTone { alert, warn, info }

/// Tinted one-line notice with an optional action on the right.
class InlineBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onTap;
  final BannerTone tone;

  const InlineBanner({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onTap,
    this.tone = BannerTone.alert,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg) = switch (tone) {
      BannerTone.alert => (c.alertSoft, c.alert),
      BannerTone.warn => (c.warnSoft, c.warn),
      BannerTone.info => (c.coinSoft, c.coin),
    };
    final style = AppTextStyles.bodySmall.copyWith(color: fg, fontSize: 13);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Icon(icon, size: 19, color: fg),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: title,
                      style: style.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (message != null) TextSpan(text: ' $message'),
                  ]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(width: 8),
                Text(
                  actionLabel!,
                  style: style.copyWith(fontWeight: FontWeight.w600),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
