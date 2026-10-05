import 'package:equatable/equatable.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../orders/domain/entities/order_discount.dart';

/// A discount the shop offers often ("Loyal customer 10%", "Bundle ₱50").
/// Orders copy it, so editing or deleting a preset never changes them.
class DiscountPreset extends Equatable {
  final int? id;
  final String label;
  final DiscountKind kind;
  final double value;
  final int position;

  const DiscountPreset({
    this.id,
    required this.label,
    required this.kind,
    required this.value,
    this.position = 0,
  });

  OrderDiscount toDiscount() =>
      OrderDiscount(label: label, kind: kind, value: value);

  @override
  List<Object?> get props => [id, label, kind, value, position];
}

/// "10%" or "₱50".
String discountValueLabel(DiscountKind kind, double value) {
  final whole = value == value.roundToDouble();
  return switch (kind) {
    DiscountKind.percent =>
      '${whole ? value.toStringAsFixed(0) : value.toStringAsFixed(1)}%',
    DiscountKind.fixed => CurrencyFormatter.formatShort(value),
  };
}
