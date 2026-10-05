import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/channel.dart';
import 'order.dart';
import 'order_discount.dart';

/// Every amount on one order, worked out in one place.
///
/// ```
/// discount     = Σ discount lines, never more than the items total
/// net          = items total − discount
/// tax          = included: net × r ÷ (1 + r)   added: net × r
/// customerPays = included: net                 added: net + tax
/// fees         = channel fees on customerPays
/// profit       = customerPays − tax − materials − fees − shipping
/// ```
///
/// With no discount and no tax this is the original
/// `sales − materials − fees − shipping`.
class OrderMoney extends Equatable {
  /// Item prices × quantities, before any discount (`orders.total_sales`).
  final double itemsTotal;
  final double discount;
  final double tax;
  final bool taxInclusive;
  final double fees;
  final double shipping;
  final double materials;

  /// The discount lines with what each took off.
  final List<OrderDiscount> discounts;

  const OrderMoney({
    required this.itemsTotal,
    this.discount = 0,
    this.tax = 0,
    this.taxInclusive = true,
    required this.fees,
    required this.shipping,
    required this.materials,
    this.discounts = const [],
  });

  /// Works the amounts out for an order about to be saved.
  ///
  /// Fees and tax are on what the customer pays after the discount, the way
  /// marketplaces charge commission. Shipping is the channel's plus
  /// [extraShipping].
  factory OrderMoney.compute({
    required double itemsTotal,
    List<OrderDiscount> discounts = const [],
    OrderTax? tax,
    Channel? channel,
    double materials = 0,
    double extraShipping = 0,
  }) {
    // Lines apply in order; once the total is used up the rest take nothing.
    var left = itemsTotal < 0 ? 0.0 : itemsTotal;
    final applied = <OrderDiscount>[];
    for (final d in discounts) {
      final amount = d.amountOn(itemsTotal).clamp(0.0, left);
      left -= amount;
      applied.add(d.withAmount(_round(amount)));
    }
    final discount = applied.fold<double>(0, (s, d) => s + d.amount);
    final net = itemsTotal - discount;

    final rate = (tax?.rate ?? 0) / 100;
    final inclusive = tax?.inclusive ?? true;
    final taxAmount = rate <= 0
        ? 0.0
        : _round(inclusive ? net * rate / (1 + rate) : net * rate);
    final customerPays = inclusive ? net : net + taxAmount;

    return OrderMoney(
      itemsTotal: itemsTotal,
      discount: discount,
      tax: taxAmount,
      taxInclusive: inclusive,
      fees: channel?.calculateFees(customerPays) ?? 0,
      shipping: (channel?.shippingPaidByUs ?? 0) + extraShipping,
      materials: materials,
      discounts: applied,
    );
  }

  /// The amounts a saved order holds. Profit is recomputed from them rather
  /// than read from `orders.profit` (business rule 5).
  factory OrderMoney.fromOrder(Order o) => OrderMoney(
        itemsTotal: o.totalSales,
        discount: o.discountTotal,
        tax: o.taxAmount,
        taxInclusive: o.taxInclusive,
        fees: o.channelFees,
        shipping: o.shippingCost,
        materials: o.totalMaterialCost,
      );

  /// Items total after discounts.
  double get net => itemsTotal - discount;

  /// The order total: what the customer hands over.
  double get customerPays => taxInclusive ? net : net + tax;

  /// What the shop keeps of [customerPays] once the tax is set aside.
  double get revenue => customerPays - tax;

  double get profit => revenue - materials - fees - shipping;

  /// Tax that comes out of the shop's sales (prices include it).
  double get includedTax => taxInclusive ? tax : 0;

  /// Tax the customer paid on top, passed straight on.
  double get addedTax => taxInclusive ? 0 : tax;

  OrderMoney withMaterials(double materials) => OrderMoney(
        itemsTotal: itemsTotal,
        discount: discount,
        tax: tax,
        taxInclusive: taxInclusive,
        fees: fees,
        shipping: shipping,
        materials: materials,
        discounts: discounts,
      );

  static double _round(double v) => (v * 100).roundToDouble() / 100;

  @override
  List<Object?> get props => [
        itemsTotal,
        discount,
        tax,
        taxInclusive,
        fees,
        shipping,
        materials,
        discounts,
      ];
}
