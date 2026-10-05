import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Totals for the packed and shipped orders in a report.
class EarningsSummary extends Equatable {
  /// Item prices before discounts.
  final double totalSales;
  final double totalMaterialCost;
  final double totalChannelFees;
  final double totalShippingCost;

  /// Stored for old callers; the page recomputes profit from the parts.
  final double totalProfit;
  final int orderCount;
  final double totalDiscount;

  /// Tax that came out of sales (prices included it).
  final double totalIncludedTax;

  /// Tax customers paid on top, passed on.
  final double totalAddedTax;

  /// What customers still owe on these orders.
  final double unpaidTotal;
  final int unpaidCount;

  const EarningsSummary({
    required this.totalSales,
    required this.totalMaterialCost,
    required this.totalChannelFees,
    required this.totalShippingCost,
    required this.totalProfit,
    required this.orderCount,
    this.totalDiscount = 0,
    this.totalIncludedTax = 0,
    this.totalAddedTax = 0,
    this.unpaidTotal = 0,
    this.unpaidCount = 0,
  });

  double get totalTax => totalIncludedTax + totalAddedTax;

  /// Recomputed from the parts (business rule 5).
  double get profit =>
      totalSales -
      totalDiscount -
      totalIncludedTax -
      totalMaterialCost -
      totalChannelFees -
      totalShippingCost;

  @override
  List<Object?> get props => [
        totalSales,
        totalMaterialCost,
        totalChannelFees,
        totalShippingCost,
        totalProfit,
        orderCount,
        totalDiscount,
        totalIncludedTax,
        totalAddedTax,
        unpaidTotal,
        unpaidCount,
      ];
}

class WasteSummary extends Equatable {
  final int totalWasteQuantity;
  final double totalWasteCost;
  final List<WasteItem> items;

  const WasteSummary({
    required this.totalWasteQuantity,
    required this.totalWasteCost,
    this.items = const [],
  });

  @override
  List<Object?> get props => [totalWasteQuantity, totalWasteCost, items];
}

class WasteItem extends Equatable {
  final String materialName;

  /// The material's unit label, so the amount wasted reads as "2 pc" or
  /// "0.5 m" rather than a bare number.
  final String unit;
  final int quantity;
  final double cost;

  const WasteItem({
    required this.materialName,
    this.unit = AppConstants.defaultUnitLabel,
    required this.quantity,
    required this.cost,
  });

  @override
  List<Object?> get props => [materialName, unit, quantity, cost];
}
