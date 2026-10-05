import 'package:equatable/equatable.dart';

enum DiscountKind {
  /// A share of the items total, in percent.
  percent,

  /// A set amount of money.
  fixed;

  static DiscountKind fromName(String name) =>
      name == 'fixed' ? DiscountKind.fixed : DiscountKind.percent;
}

/// One discount line on an order: "Loyal customer −10%", "Promo −₱50".
class OrderDiscount extends Equatable {
  final String label;
  final DiscountKind kind;

  /// Percent (0–100) or money, depending on [kind].
  final double value;

  /// What this line took off the order, as last worked out by `OrderMoney`.
  /// Zero until then.
  final double amount;

  const OrderDiscount({
    required this.label,
    required this.kind,
    required this.value,
    this.amount = 0,
  });

  /// What this line takes off [itemsTotal], before any cap.
  double amountOn(double itemsTotal) => switch (kind) {
        DiscountKind.percent => itemsTotal * value / 100,
        DiscountKind.fixed => value,
      };

  OrderDiscount withAmount(double amount) =>
      OrderDiscount(label: label, kind: kind, value: value, amount: amount);

  @override
  List<Object?> get props => [label, kind, value, amount];
}

/// The tax on one order, copied from Settings when it was saved so a later
/// change of rate doesn't rewrite old orders.
class OrderTax extends Equatable {
  /// In percent, e.g. 12 for 12% VAT.
  final double rate;

  /// True when the item prices already include the tax; false when it is
  /// added on top for the customer to pay.
  final bool inclusive;

  const OrderTax({required this.rate, required this.inclusive});

  @override
  List<Object?> get props => [rate, inclusive];
}

/// What an order offers and charges beyond its item prices: discounts, tax
/// and whether it has been paid.
class OrderTerms extends Equatable {
  final List<OrderDiscount> discounts;
  final OrderTax? tax;
  final bool isPaid;

  const OrderTerms({this.discounts = const [], this.tax, this.isPaid = true});

  OrderTerms copyWith({
    List<OrderDiscount>? discounts,
    OrderTax? tax,
    bool clearTax = false,
    bool? isPaid,
  }) =>
      OrderTerms(
        discounts: discounts ?? this.discounts,
        tax: clearTax ? null : (tax ?? this.tax),
        isPaid: isPaid ?? this.isPaid,
      );

  @override
  List<Object?> get props => [discounts, tax, isPaid];
}
