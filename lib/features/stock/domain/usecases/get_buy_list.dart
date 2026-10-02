import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/buy_list_item.dart';
import '../repositories/material_repository.dart';

class GetBuyList {
  final MaterialRepository repository;

  GetBuyList(this.repository);

  Future<Either<Failure, List<BuyListItem>>> call() async {
    return repository.getBuyList();
  }
}
