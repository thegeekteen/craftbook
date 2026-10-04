import 'package:craftbook/core/error/result.dart';

import '../entities/product_history_entry.dart';
import '../entities/product_stock_movement.dart';
import '../repositories/product_repository.dart';

/// A product's stock changes and orders as one timeline, newest first.
class GetProductHistory {
  final ProductRepository repository;

  GetProductHistory(this.repository);

  Future<Result<List<ProductHistoryEntry>>> call(int productId) async {
    final movements = await repository.getProductStockMovements(productId);
    final sales = await repository.getProductSales(productId);
    switch ((movements, sales)) {
      case (Error(:final failure), _) || (_, Error(:final failure)):
        return Error(failure);
      case (Success(value: final mv), Success(value: final sl)):
        final entries = <ProductHistoryEntry>[
          // Packing writes a 'deducted' movement for the same pieces the
          // order row already shows, so listing both would count them twice.
          for (final m in mv)
            if (m.type != ProductStockMovementType.deducted)
              StockHistoryEntry(m),
          for (final s in sl) SaleHistoryEntry(s),
        ]..sort((a, b) => b.date.compareTo(a.date));
        return Success(entries);
    }
  }
}
