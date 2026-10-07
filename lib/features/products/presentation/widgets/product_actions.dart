import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/update_product.dart';

enum _ProductAction { edit, receive, toggleArchived, delete }

/// What a product can do from wherever it's listed.
abstract final class ProductActions {
  /// The long-press menu. Returns true when something changed and the
  /// caller should reload.
  static Future<bool> open(BuildContext context, Product product) async {
    final l10n = context.l10n;
    final action = await showActionSheet<_ProductAction>(
      context,
      title: product.name,
      actions: [
        SheetAction(
            value: _ProductAction.edit,
            icon: Icons.edit_outlined,
            label: l10n.productsActionEdit),
        if (product.isStandalone)
          SheetAction(
              value: _ProductAction.receive,
              icon: Icons.add_rounded,
              label: l10n.productsActionReceive),
        SheetAction(
          value: _ProductAction.toggleArchived,
          icon: product.isArchived
              ? Icons.unarchive_outlined
              : Icons.archive_outlined,
          label: product.isArchived ? l10n.commonUnarchive : l10n.commonArchive,
        ),
        SheetAction(
            value: _ProductAction.delete,
            icon: Icons.delete_outline_rounded,
            label: l10n.productsActionDelete,
            destructive: true),
      ],
    );
    if (action == null || !context.mounted) return false;
    final id = product.id!;
    switch (action) {
      case _ProductAction.edit:
        return await context.push<bool>(RouteNames.productEditorPath(id)) ==
            true;
      case _ProductAction.receive:
        return await context
                .push<bool>(RouteNames.receiveProductStockPath(id)) ==
            true;
      case _ProductAction.toggleArchived:
        return setArchived(context, product, !product.isArchived);
      case _ProductAction.delete:
        return delete(context, product);
    }
  }

  /// Archives or unarchives. Returns true once it changed.
  static Future<bool> setArchived(
      BuildContext context, Product product, bool archived) async {
    final l10n = context.l10n;
    final result =
        await getIt<UpdateProduct>()(id: product.id!, isArchived: archived);
    if (!context.mounted) return false;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
        return false;
      case Success():
        context.showSnackBar(archived
            ? l10n.productsArchivedSnack(product.name)
            : l10n.productsUnarchivedSnack(product.name));
        return true;
    }
  }

  /// Confirms, then deletes. Returns true once the product is gone; a
  /// blocked delete explains itself in a snackbar.
  static Future<bool> delete(BuildContext context, Product product) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.productsDeleteTitle(product.name),
      message: l10n.productsDeleteMessage,
      confirmText: l10n.commonDelete,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return false;
    final result = await getIt<DeleteProduct>()(product.id!);
    if (!context.mounted) return false;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
        return false;
      case Success():
        context.showSnackBar(l10n.productsDeletedSnack);
        return true;
    }
  }
}
