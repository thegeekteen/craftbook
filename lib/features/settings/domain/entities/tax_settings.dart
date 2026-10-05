import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order_discount.dart';

/// The shop's tax: whether new orders get it, the rate, and whether prices
/// already include it.
class TaxSettings extends Equatable {
  final bool enabled;

  /// In percent, e.g. 12 for 12% VAT.
  final double rate;
  final bool inclusive;

  /// What the tax is called on orders and reports ("VAT", "GST"…).
  final String label;

  const TaxSettings({
    this.enabled = false,
    this.rate = 12,
    this.inclusive = true,
    this.label = defaultLabel,
  });

  static const defaultLabel = 'VAT';

  /// The tax a new order starts with, which the order can switch off;
  /// null when the shop doesn't charge tax.
  OrderTax? get forNewOrder =>
      enabled && rate > 0 ? OrderTax(rate: rate, inclusive: inclusive) : null;

  TaxSettings copyWith({
    bool? enabled,
    double? rate,
    bool? inclusive,
    String? label,
  }) =>
      TaxSettings(
        enabled: enabled ?? this.enabled,
        rate: rate ?? this.rate,
        inclusive: inclusive ?? this.inclusive,
        label: label ?? this.label,
      );

  @override
  List<Object?> get props => [enabled, rate, inclusive, label];
}
