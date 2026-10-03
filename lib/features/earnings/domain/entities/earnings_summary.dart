import 'package:equatable/equatable.dart';

class EarningsSummary extends Equatable {
  final double totalSales;
  final double totalMaterialCost;
  final double totalChannelFees;
  final double totalShippingCost;
  final double totalProfit;
  final int orderCount;

  const EarningsSummary({
    required this.totalSales,
    required this.totalMaterialCost,
    required this.totalChannelFees,
    required this.totalShippingCost,
    required this.totalProfit,
    required this.orderCount,
  });

  @override
  List<Object?> get props => [
        totalSales,
        totalMaterialCost,
        totalChannelFees,
        totalShippingCost,
        totalProfit,
        orderCount,
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
  final int quantity;
  final double cost;

  const WasteItem({
    required this.materialName,
    required this.quantity,
    required this.cost,
  });

  @override
  List<Object?> get props => [materialName, quantity, cost];
}
