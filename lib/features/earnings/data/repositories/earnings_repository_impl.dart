import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../database/daos/earnings_dao.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/product_earnings.dart';
// WasteItem is exported from earnings_summary.dart
import '../../domain/repositories/earnings_repository.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsDao dao;

  EarningsRepositoryImpl(this.dao);

  @override
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await dao.getEarningsSummary(startDate, endDate);
      return Right(EarningsSummary(
        totalSales: result['totalSales'] as double,
        totalMaterialCost: result['totalMaterialCost'] as double,
        totalChannelFees: result['totalChannelFees'] as double,
        totalShippingCost: result['totalShippingCost'] as double,
        totalProfit: result['totalProfit'] as double,
        orderCount: result['orderCount'] as int,
      ));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEarnings>>> getProductEarnings(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final results = await dao.getEarningsByProduct(startDate, endDate);
      return Right(results
          .map((m) => ProductEarnings(
                productId: m['productId'] as int,
                productName: m['productName'] as String? ?? '',
                quantitySold: m['quantity'] as int,
                totalSales: m['sales'] as double,
                totalProfit: m['profit'] as double,
              ))
          .toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WasteSummary>> getWasteSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await dao.getWasteSummary(startDate, endDate);
      final rawItems = result['items'] as List<dynamic>? ?? [];
      final wasteItems = rawItems
          .map((m) => WasteItem(
                materialName: m['materialName'] as String? ?? '',
                quantity: m['quantity'] as int,
                cost: m['cost'] as double,
              ))
          .toList();

      return Right(WasteSummary(
        totalWasteQuantity: result['totalWasteQuantity'] as int,
        totalWasteCost: result['totalWasteCost'] as double,
        items: wasteItems,
      ));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
