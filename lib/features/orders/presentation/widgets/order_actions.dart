import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/extensions.dart';
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
    final action = await showActionSheet<_OrderAction>(
      context,
      title: 'Order #${order.id} · ${order.customerName}',
      actions: [
        if (order.status == OrderStatus.packed)
          const SheetAction(
              value: _OrderAction.ship,
              icon: Icons.local_shipping_rounded,
              label: 'Mark shipped'),
        if (!cancelled)
          SheetAction(
              value: _OrderAction.paid,
              icon: order.isPaid
                  ? Icons.money_off_rounded
                  : Icons.payments_outlined,
              label: order.isPaid ? 'Mark unpaid' : 'Mark paid'),
        if (!cancelled)
          SheetAction(
              value: _OrderAction.edit,
              icon: Icons.edit_outlined,
              label: shipped ? 'Edit note' : 'Edit order'),
        if (canCancel(order))
          const SheetAction(
              value: _OrderAction.cancel,
              icon: Icons.block_rounded,
              label: 'Cancel order'),
        if (cancelled)
          const SheetAction(
              value: _OrderAction.restore,
              icon: Icons.restore_rounded,
              label: 'Restore order'),
        if (!shipped)
          const SheetAction(
              value: _OrderAction.delete,
              icon: Icons.delete_outline_rounded,
              label: 'Delete order',
              destructive: true),
      ],
    );
    if (action == null || !context.mounted) return false;
    final id = order.id!;
    switch (action) {
      case _OrderAction.ship:
        return _run(context, getIt<ShipOrder>()(id), 'Marked as shipped');
      case _OrderAction.paid:
        return _run(context, getIt<SetOrderPaid>()(id, !order.isPaid),
            order.isPaid ? 'Marked as unpaid' : 'Marked as paid');
      case _OrderAction.edit:
        return await context.push<bool>(RouteNames.editOrderPath(id)) == true;
      case _OrderAction.cancel:
        if (!await confirmCancel(context, order) || !context.mounted) {
          return false;
        }
        return _run(context, getIt<CancelOrder>()(id),
            'Order cancelled. Stock returned.');
      case _OrderAction.restore:
        if (!await confirmRestore(context, order) || !context.mounted) {
          return false;
        }
        return _run(context, getIt<RestoreOrder>()(id), 'Order restored');
      case _OrderAction.delete:
        if (!await confirmDelete(context, order) || !context.mounted) {
          return false;
        }
        return _run(context, getIt<DeleteOrder>()(id), 'Order deleted');
    }
  }

  /// Any order still in play can be called off; a shipped one when it came
  /// back or never went, so it can then be deleted.
  static bool canCancel(Order order) => order.status != OrderStatus.cancelled;

  static Future<bool> confirmCancel(BuildContext context, Order order) {
    return ConfirmDialog.show(
      context,
      title: 'Cancel order #${order.id}?',
      message: order.status == OrderStatus.shipped
          ? "Use this when it came back or never went out. Its materials go back on the shelf, and the order stays in your list as cancelled, out of your reports. You can delete it after."
          : order.status == OrderStatus.packed
              ? "Its materials go back on the shelf. The order stays in your list as cancelled and doesn't count toward earnings."
              : "Its reserved stock is released. The order stays in your list as cancelled and doesn't count toward earnings.",
      confirmText: 'Cancel order',
      cancelText: 'Keep order',
      isDestructive: true,
    );
  }

  static Future<bool> confirmRestore(BuildContext context, Order order) {
    return ConfirmDialog.show(
      context,
      title: 'Restore order #${order.id}?',
      message: 'It goes back to To pack and reserves its materials again.',
      confirmText: 'Restore',
    );
  }

  /// Asks before deleting; what happens to the stock depends on status.
  static Future<bool> confirmDelete(BuildContext context, Order order) {
    return ConfirmDialog.show(
      context,
      title: 'Delete order #${order.id}?',
      message: switch (order.status) {
        OrderStatus.packed =>
          'The order is removed and its materials go back on the shelf.',
        OrderStatus.cancelled => 'The cancelled order is removed for good.',
        _ => 'The order is removed and its reserved stock is released.',
      },
      confirmText: 'Delete',
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
