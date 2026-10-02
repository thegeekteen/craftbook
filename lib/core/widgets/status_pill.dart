import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Status pill badge widget
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexMono',
          letterSpacing: 0.06,
          color: _textColor,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case StatusPillType.success:
        return AppColors.successSoft;
      case StatusPillType.alert:
        return AppColors.alertSoft;
      case StatusPillType.warning:
        return AppColors.warningSoft;
      case StatusPillType.coin:
        return AppColors.coinSoft;
      case StatusPillType.ink:
        return AppColors.ink;
      case StatusPillType.neutral:
        return AppColors.hair;
    }
  }

  Color get _textColor {
    switch (type) {
      case StatusPillType.success:
        return AppColors.success;
      case StatusPillType.alert:
        return AppColors.alert;
      case StatusPillType.warning:
        return AppColors.warning;
      case StatusPillType.coin:
        return AppColors.coin;
      case StatusPillType.ink:
        return Colors.white;
      case StatusPillType.neutral:
        return AppColors.ink;
    }
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
