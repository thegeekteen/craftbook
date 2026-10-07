import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_detail_state.dart';

/// Labels for the orders feature that need the user's language, kept out of
/// the domain layer.
extension OrderStatusL10n on OrderStatus {
  /// User-facing name. Pending orders are called "To pack" everywhere.
  String localized(AppLocalizations l10n) => switch (this) {
        OrderStatus.pending => l10n.ordersStatusToPack,
        OrderStatus.packed => l10n.ordersStatusPacked,
        OrderStatus.shipped => l10n.ordersStatusShipped,
        OrderStatus.cancelled => l10n.ordersStatusCancelled,
      };
}

/// "1 item" / "2.5 items" for a count of pieces on an order.
String itemCountLabel(AppLocalizations l10n, double pieces) =>
    l10n.ordersItemCount(pieces, QuantityFormatter.format(pieces));

/// "Today", "Tomorrow", "Yesterday", "Wed, Oct 7", or "Oct 7, 2025" outside
/// the current year, in the app's language.
String friendlyDate(BuildContext context, DateTime date, {DateTime? now}) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toString();
  final today = app_date.DateUtils.startOfDay(now ?? DateTime.now());
  final diff = app_date.DateUtils.startOfDay(date).difference(today).inDays;
  if (diff == 0) return l10n.ordersDateToday;
  if (diff == 1) return l10n.ordersDateTomorrow;
  if (diff == -1) return l10n.ordersDateYesterday;
  if (date.year != today.year) {
    return DateFormat('MMM d, y', locale).format(date);
  }
  return DateFormat('EEE, MMM d', locale).format(date);
}

/// The shop's waste reasons are stored in English; known ones are shown in
/// the app's language, anything else (typed or older) as it is.
String wasteReasonLabel(AppLocalizations l10n, String reason) =>
    switch (reason) {
      'Cutting' => l10n.ordersWasteCutting,
      'Defect' => l10n.ordersWasteDefect,
      'Miscount' => l10n.ordersWasteMiscount,
      'Other' => l10n.ordersWasteOther,
      _ => reason,
    };

extension OrderNoticeL10n on OrderNotice {
  String localized(AppLocalizations l10n) => switch (this) {
        OrderNotice.materialsUpdated => l10n.ordersToastMaterialsUpdated,
        OrderNotice.packed => l10n.ordersToastPacked,
        OrderNotice.shipped => l10n.ordersToastShipped,
        OrderNotice.paid => l10n.ordersToastPaid,
        OrderNotice.unpaid => l10n.ordersToastUnpaid,
        OrderNotice.cancelled => l10n.ordersToastCancelled,
        OrderNotice.restored => l10n.ordersToastRestored,
      };
}
