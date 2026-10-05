import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_money.dart';

/// Any, or only orders with / without something.
enum Presence { any, with_, without }

enum PaymentFilter { any, paid, unpaid }

/// Narrows a report to some orders. Empty sets and nulls mean "don't
/// filter on this".
class ReportFilter extends Equatable {
  final Set<int> channelIds;

  /// Orders containing at least one of these products.
  final Set<int> productIds;

  /// Packed and/or shipped; empty means both.
  final Set<OrderStatus> statuses;
  final PaymentFilter payment;
  final Presence discount;
  final Presence tax;

  /// Bounds on what the customer paid, inclusive.
  final double? minTotal;
  final double? maxTotal;

  const ReportFilter({
    this.channelIds = const {},
    this.productIds = const {},
    this.statuses = const {},
    this.payment = PaymentFilter.any,
    this.discount = Presence.any,
    this.tax = Presence.any,
    this.minTotal,
    this.maxTotal,
  });

  static const none = ReportFilter();

  bool get isEmpty => activeCount == 0;

  /// How many kinds of filter are set, for the badge on the filter button.
  int get activeCount => [
        channelIds.isNotEmpty,
        productIds.isNotEmpty,
        statuses.isNotEmpty,
        payment != PaymentFilter.any,
        discount != Presence.any,
        tax != Presence.any,
        minTotal != null || maxTotal != null,
      ].where((on) => on).length;

  /// Whether [order], holding [orderProductIds], is in the report.
  bool matches(Order order, Set<int> orderProductIds) {
    if (channelIds.isNotEmpty && !channelIds.contains(order.channelId)) {
      return false;
    }
    if (productIds.isNotEmpty &&
        !orderProductIds.any((id) => productIds.contains(id))) {
      return false;
    }
    if (statuses.isNotEmpty && !statuses.contains(order.status)) return false;
    switch (payment) {
      case PaymentFilter.paid when !order.isPaid:
      case PaymentFilter.unpaid when order.isPaid:
        return false;
      default:
    }
    if (!_presence(discount, order.hasDiscount)) return false;
    if (!_presence(tax, order.hasTax)) return false;
    if (minTotal != null || maxTotal != null) {
      final total = OrderMoney.fromOrder(order).customerPays;
      if (minTotal != null && total < minTotal! - 0.005) return false;
      if (maxTotal != null && total > maxTotal! + 0.005) return false;
    }
    return true;
  }

  static bool _presence(Presence p, bool has) => switch (p) {
        Presence.any => true,
        Presence.with_ => has,
        Presence.without => !has,
      };

  ReportFilter copyWith({
    Set<int>? channelIds,
    Set<int>? productIds,
    Set<OrderStatus>? statuses,
    PaymentFilter? payment,
    Presence? discount,
    Presence? tax,
    double? minTotal,
    bool clearMinTotal = false,
    double? maxTotal,
    bool clearMaxTotal = false,
  }) =>
      ReportFilter(
        channelIds: channelIds ?? this.channelIds,
        productIds: productIds ?? this.productIds,
        statuses: statuses ?? this.statuses,
        payment: payment ?? this.payment,
        discount: discount ?? this.discount,
        tax: tax ?? this.tax,
        minTotal: clearMinTotal ? null : (minTotal ?? this.minTotal),
        maxTotal: clearMaxTotal ? null : (maxTotal ?? this.maxTotal),
      );

  @override
  List<Object?> get props => [
        channelIds,
        productIds,
        statuses,
        payment,
        discount,
        tax,
        minTotal,
        maxTotal,
      ];
}
