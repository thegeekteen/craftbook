import 'package:flutter/material.dart' hide Material;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/material.dart';
import '../../domain/usecases/delete_material.dart';
import '../../domain/usecases/set_material_archived.dart';

enum _MaterialAction { receive, edit, toggleArchived, delete }

/// What a material can do from wherever it's listed.
abstract final class MaterialActions {
  /// The long-press menu. Returns true when something changed and the
  /// caller should reload.
  static Future<bool> open(BuildContext context, Material material) async {
    final action = await showActionSheet<_MaterialAction>(
      context,
      title: material.name,
      actions: [
        const SheetAction(
            value: _MaterialAction.receive,
            icon: Icons.add_rounded,
            label: 'Receive stock'),
        const SheetAction(
            value: _MaterialAction.edit,
            icon: Icons.edit_outlined,
            label: 'Edit material'),
        SheetAction(
          value: _MaterialAction.toggleArchived,
          icon: material.isArchived
              ? Icons.unarchive_outlined
              : Icons.archive_outlined,
          label: material.isArchived ? 'Unarchive' : 'Archive',
        ),
        const SheetAction(
            value: _MaterialAction.delete,
            icon: Icons.delete_outline_rounded,
            label: 'Delete material',
            destructive: true),
      ],
    );
    if (action == null || !context.mounted) return false;
    final id = material.id!;
    switch (action) {
      case _MaterialAction.receive:
        return await context.push<bool>(RouteNames.receiveStockPath(id)) ==
            true;
      case _MaterialAction.edit:
        return await context.push<bool>(RouteNames.editMaterialPath(id)) ==
            true;
      case _MaterialAction.toggleArchived:
        return setArchived(context, material, !material.isArchived);
      case _MaterialAction.delete:
        return delete(context, material);
    }
  }

  /// Archives or unarchives. Returns true once it changed.
  static Future<bool> setArchived(
      BuildContext context, Material material, bool archived) async {
    final result =
        await getIt<SetMaterialArchived>()(material.id!, archived: archived);
    if (!context.mounted) return false;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
        return false;
      case Success():
        context.showSnackBar(archived
            ? '${material.name} archived'
            : '${material.name} is back in your lists');
        return true;
    }
  }

  /// Confirms, then deletes. Returns true once the material is gone; a
  /// blocked delete explains itself in a snackbar.
  static Future<bool> delete(BuildContext context, Material material) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete ${material.name}?',
      message: [
        "This can't be undone. Materials used in a product or an order can't be deleted; archive them instead.",
        if (material.quantityOnHand > 0)
          'You still have ${material.quantityOnHand} on hand. Its stock history goes too.',
      ].join('\n\n'),
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return false;
    final result = await getIt<DeleteMaterial>()(material.id!);
    if (!context.mounted) return false;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
        return false;
      case Success():
        context.showSnackBar('${material.name} deleted');
        return true;
    }
  }
}
