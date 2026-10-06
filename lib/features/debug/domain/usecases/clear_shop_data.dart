import '../../../../core/error/result.dart';
import '../repositories/shop_data_repository.dart';

/// Empties the shop back to a fresh install.
///
/// Settings rows go with it, so the app's own defaults come back on the next
/// launch — which is why the Debug row restarts the app afterwards rather than
/// trying to update screens that no longer have anything to show.
class ClearShopData {
  final ShopDataRepository shopData;

  const ClearShopData(this.shopData);

  Future<Result<void>> call() async {
    switch (await shopData.wipeAll()) {
      case Error(:final failure):
        return Error<void>(failure);
      case Success():
        return const Success<void>(null);
    }
  }
}
