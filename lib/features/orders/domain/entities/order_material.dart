import 'package:equatable/equatable.dart';

class OrderMaterial extends Equatable {
  final int? id;
  final int orderId;
  final int materialId;
  final String materialName;
  final int plannedQuantity;
  final int actualQuantity;
  final int wasteQuantity;
  final String? wasteReason;
  final double unitCost;
  final DateTime createdAt;

  const OrderMaterial({
    this.id,
    required this.orderId,
    required this.materialId,
    required this.materialName,
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
  final int plannedQuantity;
  final int actualQuantity;
  final int wasteQuantity;
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
