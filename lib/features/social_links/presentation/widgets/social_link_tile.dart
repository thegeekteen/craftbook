import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/social_link.dart';
import 'social_mark.dart';

/// A shortcut as a card in the grid: the mark, its name and the address.
class SocialLinkTile extends StatelessWidget {
  final SocialLink link;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const SocialLinkTile(
      {super.key, required this.link, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: 'Open ${link.label}',
      child: AppCard(
        onTap: onTap,
        onLongPress: onLongPress,
        padding: const EdgeInsets.all(14),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SocialMark(color: link.tileColor, glyph: link.glyph),
                  const Spacer(),
                  Icon(Icons.north_east_rounded, size: 18, color: c.muted),
                ],
              ),
              const Spacer(),
              Text(
                link.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: c.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                link.displayUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: c.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
