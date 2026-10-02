import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../stock/domain/repositories/material_repository.dart';

class GetAlertSummary {
  final MaterialRepository repository;

  GetAlertSummary(this.repository);

  Future<Either<Failure, AlertSummary>> call() async {
    final result = await repository.getLowStockMaterials();
    return result.fold(
      (failure) => Left(failure),
      (materials) => Right(AlertSummary(
        lowStockCount: materials.length,
        materialNames: materials.map((m) => m.name).toList(),
      )),
    );
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
