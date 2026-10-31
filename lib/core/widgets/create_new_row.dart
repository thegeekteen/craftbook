import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// The "+ New product" row at the top of a picker: makes the thing you were
/// looking for without leaving what you're doing.
class CreateNewRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const CreateNewRow({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(color: c.goSoft, shape: BoxShape.circle),
              child: Icon(Icons.add_rounded, color: c.go, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: c.go, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
