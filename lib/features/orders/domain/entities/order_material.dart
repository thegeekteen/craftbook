import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

class OrderMaterial extends Equatable {
  final int? id;
  final int orderId;
  final int materialId;
  final String materialName;

  /// The material's unit label, looked up with its name. Not stored on the
  /// order, so renaming the unit reaches past orders too.
  final String materialUnit;
  final double plannedQuantity;
  final double actualQuantity;
  final double wasteQuantity;
  final String? wasteReason;
  final double unitCost;
  final DateTime createdAt;

  const OrderMaterial({
    this.id,
    required this.orderId,
    required this.materialId,
    required this.materialName,
    this.materialUnit = AppConstants.defaultUnitLabel,
    required this.plannedQuantity,
    required this.actualQuantity,
    required this.wasteQuantity,
    this.wasteReason,
    required this.unitCost,
    required this.createdAt,
  });

  double get totalCost => actualQuantity * unitCost;

  @override
  List<Object?> get props => [
        id,
        orderId,
        materialId,
        materialName,
        materialUnit,
        plannedQuantity,
        actualQuantity,
        wasteQuantity,
        wasteReason,
        unitCost,
        createdAt,
      ];
}

/// Input for creating/updating order materials
class OrderMaterialInput extends Equatable {
  final int materialId;
  final String materialName;
  final double plannedQuantity;
  final double actualQuantity;
  final double wasteQuantity;
  final String? wasteReason;
  final double unitCost;

  const OrderMaterialInput({
    required this.materialId,
    required this.materialName,
    required this.plannedQuantity,
    required this.actualQuantity,
    this.wasteQuantity = 0,
    this.wasteReason,
    required this.unitCost,
  });

  @override
  List<Object?> get props => [
        materialId,
        materialName,
        plannedQuantity,
        actualQuantity,
        wasteQuantity,
        wasteReason,
        unitCost,
      ];
}
