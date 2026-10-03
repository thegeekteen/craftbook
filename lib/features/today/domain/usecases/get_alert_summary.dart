import '../../../../core/error/result.dart';
import '../../../stock/domain/repositories/material_repository.dart';

class GetAlertSummary {
  final MaterialRepository repository;

  GetAlertSummary(this.repository);

  Future<Result<AlertSummary>> call() async {
    final result = await repository.getLowStockMaterials();
    switch (result) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        return Success(AlertSummary(
          lowStockCount: value.length,
          materialNames: value.map((m) => m.name).toList(),
        ));
    }
  }
}

class AlertSummary {
  final int lowStockCount;
  final List<String> materialNames;

  const AlertSummary({
    required this.lowStockCount,
    required this.materialNames,
  });

  bool get hasAlerts => lowStockCount > 0;
}
