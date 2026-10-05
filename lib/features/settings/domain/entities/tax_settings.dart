import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order_discount.dart';

/// The shop's tax: whether orders can have it, whether new ones start with
/// it, the rate, and whether prices already include it.
class TaxSettings extends Equatable {
  /// Tax is in use: orders get a tax switch.
  final bool enabled;

  /// New orders start with tax on. Off suits shops that only add it when a
  /// customer asks for an official receipt.
  final bool onByDefault;

  /// In percent, e.g. 12 for 12% VAT.
  final double rate;
  final bool inclusive;

  /// What the tax is called on orders and reports ("VAT", "GST"…).
  final String label;

  const TaxSettings({
    this.enabled = false,
    this.onByDefault = true,
    this.rate = 12,
    this.inclusive = true,
    this.label = defaultLabel,
  });

  static const defaultLabel = 'VAT';

  /// The tax an order gets when its switch is on; null when the shop
  /// doesn't use tax, so no switch is offered.
  OrderTax? get available =>
      enabled && rate > 0 ? OrderTax(rate: rate, inclusive: inclusive) : null;

  /// The tax a new order starts with; null when it starts without.
  OrderTax? get forNewOrder => onByDefault ? available : null;

  TaxSettings copyWith({
    bool? enabled,
    bool? onByDefault,
    double? rate,
    bool? inclusive,
    String? label,
  }) =>
      TaxSettings(
        enabled: enabled ?? this.enabled,
        onByDefault: onByDefault ?? this.onByDefault,
        rate: rate ?? this.rate,
        inclusive: inclusive ?? this.inclusive,
        label: label ?? this.label,
      );

  @override
  List<Object?> get props => [enabled, onByDefault, rate, inclusive, label];
}
