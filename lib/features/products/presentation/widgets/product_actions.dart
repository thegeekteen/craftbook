import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/update_product.dart';

enum _ProductAction { edit, receive, toggleActive, delete }

/// What a product can do from wherever it's listed.
abstract final class ProductActions {
  /// The long-press menu. Returns true when something changed and the
  /// caller should reload.
  static Future<bool> open(BuildContext context, Product product) async {
    final action = await showActionSheet<_ProductAction>(
      context,
      title: product.name,
      actions: [
        const SheetAction(
            value: _ProductAction.edit,
            icon: Icons.edit_outlined,
            label: 'Edit product'),
        if (product.isStandalone)
          const SheetAction(
              value: _ProductAction.receive,
              icon: Icons.add_rounded,
              label: 'Receive stock'),
        SheetAction(
          value: _ProductAction.toggleActive,
          icon: product.isActive
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          label: product.isActive ? 'Hide from new orders' : 'Show again',
        ),
        const SheetAction(
            value: _ProductAction.delete,
            icon: Icons.delete_outline_rounded,
            label: 'Delete product',
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
      case _ProductAction.toggleActive:
        return _setActive(context, product, !product.isActive);
      case _ProductAction.delete:
        return delete(context, product);
    }
  }

  static Future<bool> _setActive(
      BuildContext context, Product product, bool active) async {
    final result =
        await getIt<UpdateProduct>()(id: product.id!, isActive: active);
    if (!context.mounted) return false;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
        return false;
      case Success():
        context.showSnackBar(active
            ? '${product.name} shows in new orders'
            : '${product.name} hidden from new orders');
        return true;
    }
  }

  /// Confirms, then deletes. Returns true once the product is gone; a
  /// blocked delete explains itself in a snackbar.
  static Future<bool> delete(BuildContext context, Product product) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete ${product.name}?',
      message:
          "This can't be undone. Products that appear in orders can't be deleted; hide them instead.",
      confirmText: 'Delete',
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
        context.showSnackBar('Product deleted');
        return true;
    }
  }
}
