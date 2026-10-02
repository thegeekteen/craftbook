import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/buy_list_item.dart';
import '../repositories/material_repository.dart';

class GetBlockedProducts {
  final MaterialRepository repository;

  GetBlockedProducts(this.repository);

  Future<Either<Failure, List<BuyListItem>>> call() async {
    final result = await repository.getBuyList();
    return result.fold(
      (failure) => Left(failure),
      (items) => Right(items.where((item) => item.blockedProducts.isNotEmpty).toList()),
    );
  }
}
