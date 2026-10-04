import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'app_sheet.dart';

/// One choice in an [showActionSheet] menu.
class SheetAction<T> {
  final T value;
  final IconData icon;
  final String label;

  /// Drawn in the alert colour, for deletes and other one-way doors.
  final bool destructive;

  const SheetAction({
    required this.value,
    required this.icon,
    required this.label,
    this.destructive = false,
  });
}

/// The long-press menu: a bottom sheet listing [actions].
///
/// The sheet only picks an action and returns its value (null when
/// dismissed); the caller carries it out, since a dialog can't hang off a
/// sheet that has already closed.
Future<T?> showActionSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<SheetAction<T>> actions,
}) {
  return showAppSheet<T>(
    context: context,
    title: title,
    subtitle: subtitle,
    builder: (_) => ActionSheetList<T>(actions: actions),
  );
}

/// The rows inside [showActionSheet]; public so it can be tested alone.
class ActionSheetList<T> extends StatelessWidget {
  final List<SheetAction<T>> actions;

  const ActionSheetList({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final a in actions)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(a.icon, color: a.destructive ? c.alert : null),
            title: Text(
              a.label,
              style: a.destructive ? TextStyle(color: c.alert) : null,
            ),
            onTap: () => Navigator.pop(context, a.value),
          ),
      ],
    );
  }
}
