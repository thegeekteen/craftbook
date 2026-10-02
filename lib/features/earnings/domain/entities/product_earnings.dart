import 'package:equatable/equatable.dart';

class ProductEarnings extends Equatable {
  final int productId;
  final String productName;
  final int quantitySold;
  final double totalSales;
  final double totalProfit;

  const ProductEarnings({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalSales,
    required this.totalProfit,
  });

  @override
  List<Object?> get props => [productId, productName, quantitySold, totalSales, totalProfit];
}
