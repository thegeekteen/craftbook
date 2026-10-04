import 'package:flutter/material.dart';

import 'app_card.dart';
import 'section_label.dart';

/// A [SectionLabel] followed by an [AppCard].
class SectionCard extends StatelessWidget {
  final String? label;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? backgroundColor;

  const SectionCard({
    super.key,
    this.label,
    this.trailing,
    required this.child,
    this.padding,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          SectionLabel(label!,
              trailing: trailing,
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0)),
          const SizedBox(height: 8),
        ],
        AppCard(
          padding: padding ?? const EdgeInsets.all(14),
          color: backgroundColor,
          borderColor: borderColor,
          child: child,
        ),
      ],
    );
  }
}
