import '../../../../core/error/result.dart';
import '../entities/buy_list_item.dart';
import '../repositories/material_repository.dart';

class GetBlockedProducts {
  final MaterialRepository repository;

  GetBlockedProducts(this.repository);

  Future<Result<List<BuyListItem>>> call() async {
    final result = await repository.getBuyList();
    switch (result) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        return Success(value.where((item) => item.blockedProducts.isNotEmpty).toList());
    }
  }
}
