import '../../../../core/error/result.dart';
import '../entities/buy_list_item.dart';
import '../repositories/material_repository.dart';

class GetBuyList {
  final MaterialRepository repository;

  GetBuyList(this.repository);

  Future<Result<List<BuyListItem>>> call() async {
    return repository.getBuyList();
  }
}
