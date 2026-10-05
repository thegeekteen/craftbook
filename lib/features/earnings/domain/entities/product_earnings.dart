import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

class ProductEarnings extends Equatable {
  final int productId;
  final String productName;

  /// The product's unit label, so "3 sold" can read "3 pc sold".
  final String unit;
  final double quantitySold;
  final double totalSales;
  final double totalProfit;

  const ProductEarnings({
    required this.productId,
    required this.productName,
    this.unit = AppConstants.defaultUnitLabel,
    required this.quantitySold,
    required this.totalSales,
    required this.totalProfit,
  });

  @override
  List<Object?> get props =>
      [productId, productName, unit, quantitySold, totalSales, totalProfit];
}
