import '../../../../core/error/result.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';

/// Everything on the Buy list: low materials, then low resell products.
class GetAlertSummary {
  final MaterialRepository materials;
  final ProductRepository products;

  GetAlertSummary(this.materials, this.products);

  Future<Result<AlertSummary>> call() async {
    final lowMaterials = await materials.getLowStockMaterials();
    final lowProducts = await products.getLowStockProducts();
    switch ((lowMaterials, lowProducts)) {
      case (Error(:final failure), _):
      case (_, Error(:final failure)):
        return Error(failure);
      case (Success(value: final m), Success(value: final p)):
        final names = [...m.map((x) => x.name), ...p.map((x) => x.name)];
        return Success(AlertSummary(lowStockCount: names.length, names: names));
    }
  }
}

class AlertSummary {
  final int lowStockCount;

  /// Low materials first, then low resell products.
  final List<String> names;

  const AlertSummary({
    required this.lowStockCount,
    required this.names,
  });

  bool get hasAlerts => lowStockCount > 0;
}
