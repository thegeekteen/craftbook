import 'package:equatable/equatable.dart';

import 'product_sale.dart';
import 'product_stock_movement.dart';

/// One row of a product's history: a stock change or an order.
sealed class ProductHistoryEntry extends Equatable {
  const ProductHistoryEntry();

  DateTime get date;
}

class StockHistoryEntry extends ProductHistoryEntry {
  final ProductStockMovement movement;

  const StockHistoryEntry(this.movement);

  @override
  DateTime get date => movement.createdAt;

  @override
  List<Object?> get props => [movement];
}

class SaleHistoryEntry extends ProductHistoryEntry {
  final ProductSale sale;

  const SaleHistoryEntry(this.sale);

  @override
  DateTime get date => sale.date;

  @override
  List<Object?> get props => [sale];
}
