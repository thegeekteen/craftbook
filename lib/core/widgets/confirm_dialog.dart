import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Confirmation dialog. Destructive actions get a red confirm button.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final bool isDestructive;
  final Widget? content;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.isDestructive = false,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (content != null) ...[
            const SizedBox(height: 12),
            content!,
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: c.muted),
          child: Text(cancelText ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? c.alert : c.go,
            foregroundColor: c.onAccent,
            minimumSize: const Size(0, 44),
          ),
          child: Text(confirmText ?? 'Confirm'),
        ),
      ],
    );
  }

  /// Show the confirm dialog and return the result
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    Widget? content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        content: content,
      ),
    );
    return result ?? false;
  }
}
