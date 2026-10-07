import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/delete_order.dart';
import '../../domain/usecases/restore_order.dart';
import '../../domain/usecases/set_order_paid.dart';
import '../../domain/usecases/ship_order.dart';

enum _OrderAction { ship, paid, edit, cancel, restore, delete }

/// What an order can do from wherever it's listed. Mirrors the detail
/// page's menu: shipped orders only take a note, cancelled ones can be
/// restored or deleted.
abstract final class OrderActions {
  /// The long-press menu. Returns true when something changed and the
  /// caller should reload.
  static Future<bool> open(BuildContext context, Order order) async {
    final shipped = order.status == OrderStatus.shipped;
    final cancelled = order.status == OrderStatus.cancelled;
    final l10n = context.l10n;
    final action = await showActionSheet<_OrderAction>(
      context,
      title: context.l10n.ordersActionTitle('${order.id}', order.customerName),
      actions: [
        if (order.status == OrderStatus.packed)
          SheetAction(
              value: _OrderAction.ship,
              icon: Icons.local_shipping_rounded,
              label: l10n.ordersMarkShipped),
        if (!cancelled)
          SheetAction(
              value: _OrderAction.paid,
              icon: order.isPaid
                  ? Icons.money_off_rounded
                  : Icons.payments_outlined,
              label:
                  order.isPaid ? l10n.ordersMarkUnpaid : l10n.ordersMarkPaid),
        if (!cancelled)
          SheetAction(
              value: _OrderAction.edit,
              icon: Icons.edit_outlined,
              label: shipped ? l10n.ordersEditNote : l10n.ordersEditOrder),
        if (canCancel(order))
          SheetAction(
              value: _OrderAction.cancel,
              icon: Icons.block_rounded,
              label: l10n.ordersCancelOrder),
        if (cancelled)
          SheetAction(
              value: _OrderAction.restore,
              icon: Icons.restore_rounded,
              label: l10n.ordersRestoreOrder),
        if (!shipped)
          SheetAction(
              value: _OrderAction.delete,
              icon: Icons.delete_outline_rounded,
              label: l10n.ordersDeleteOrder,
              destructive: true),
      ],
    );
    if (action == null || !context.mounted) return false;
    final id = order.id!;
    switch (action) {
      case _OrderAction.ship:
        return _run(context, getIt<ShipOrder>()(id), l10n.ordersToastShipped);
      case _OrderAction.paid:
        return _run(context, getIt<SetOrderPaid>()(id, !order.isPaid),
            order.isPaid ? l10n.ordersToastUnpaid : l10n.ordersToastPaid);
      case _OrderAction.edit:
        return await context.push<bool>(RouteNames.editOrderPath(id)) == true;
      case _OrderAction.cancel:
        if (!await confirmCancel(context, order) || !context.mounted) {
          return false;
        }
        return _run(
            context, getIt<CancelOrder>()(id), l10n.ordersToastCancelled);
      case _OrderAction.restore:
        if (!await confirmRestore(context, order) || !context.mounted) {
          return false;
        }
        return _run(
            context, getIt<RestoreOrder>()(id), l10n.ordersToastRestored);
      case _OrderAction.delete:
        if (!await confirmDelete(context, order) || !context.mounted) {
          return false;
        }
        return _run(context, getIt<DeleteOrder>()(id), l10n.ordersToastDeleted);
    }
  }

  /// Any order still in play can be called off; a shipped one when it came
  /// back or never went, so it can then be deleted.
  static bool canCancel(Order order) => order.status != OrderStatus.cancelled;

  static Future<bool> confirmCancel(BuildContext context, Order order) {
    final l10n = context.l10n;
    return ConfirmDialog.show(
      context,
      title: l10n.ordersCancelTitle('${order.id}'),
      message: order.status == OrderStatus.shipped
          ? l10n.ordersCancelMessageShipped
          : order.status == OrderStatus.packed
              ? l10n.ordersCancelMessagePacked
              : l10n.ordersCancelMessagePending,
      confirmText: l10n.ordersCancelConfirm,
      cancelText: l10n.ordersCancelKeep,
      isDestructive: true,
    );
  }

  static Future<bool> confirmRestore(BuildContext context, Order order) {
    final l10n = context.l10n;
    return ConfirmDialog.show(
      context,
      title: l10n.ordersRestoreTitle('${order.id}'),
      message: l10n.ordersRestoreMessage,
      confirmText: l10n.commonRestore,
    );
  }

  /// Asks before deleting; what happens to the stock depends on status.
  static Future<bool> confirmDelete(BuildContext context, Order order) {
    final l10n = context.l10n;
    return ConfirmDialog.show(
      context,
      title: l10n.ordersDeleteTitle('${order.id}'),
      message: switch (order.status) {
        OrderStatus.packed => l10n.ordersDeleteMessagePacked,
        OrderStatus.cancelled => l10n.ordersDeleteMessageCancelled,
        _ => l10n.ordersDeleteMessagePending,
      },
      confirmText: l10n.commonDelete,
      isDestructive: true,
    );
  }

  static Future<bool> _run(BuildContext context, Future<Result<void>> work,
      String successMessage) async {
    final result = await work;
    if (!context.mounted) return false;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
        return false;
      case Success():
        context.showSnackBar(successMessage);
        return true;
    }
  }
}
