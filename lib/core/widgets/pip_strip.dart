import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Pip strip widget - the signature visual component
/// Shows stock as individual pips: filled = free, hatched = promised
class PipStrip extends StatelessWidget {
  final int total;
  final int free;
  final int promised;
  final double pipWidth;
  final double pipHeight;
  final double spacing;
  final bool isLow;
  final bool isWarning;

  const PipStrip({
    super.key,
    required this.total,
    required this.free,
    required this.promised,
    this.pipWidth = 6,
    this.pipHeight = 9,
    this.spacing = 2,
    this.isLow = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(total, (index) {
        Color color;
        bool isHatched = false;

        if (index < free) {
          // Free pieces
          if (isLow) {
            color = AppColors.alert;
          } else if (isWarning) {
            color = AppColors.warning;
          } else {
            color = AppColors.success;
          }
        } else if (index < free + promised) {
          // Promised pieces (hatched)
          isHatched = true;
          color = AppColors.alert;
        } else {
          // Empty pieces
          color = AppColors.pipEmpty;
        }

        return Container(
          width: pipWidth,
          height: pipHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1.5),
            color: isHatched ? null : color,
            gradient: isHatched
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.alert,
                      AppColors.alertSoft,
                      AppColors.alert,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  )
                : null,
          ),
        );
      }),
    );
  }
}
