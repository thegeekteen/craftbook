import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Material entity
class Material extends Equatable {
  final int? id;
  final String name;

  /// What [packSize] and the quantities below are counted in.
  final int unitId;

  /// The unit's label, looked up with it. Rendered as typed, never pluralised.
  final String unit;
  final int packSize;
  final double packPrice;
  final double unitCost;
  final int quantityOnHand;
  final int quantityPromised;
  final int alertLevel;
  final String? supplier;
  final DateTime? lastReceivedAt;

  /// Kept for past orders but left out of lists, pickers and alerts.
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Material({
    this.id,
    required this.name,
    this.unitId = AppConstants.defaultUnitId,
    this.unit = AppConstants.defaultUnitLabel,
    required this.packSize,
    required this.packPrice,
    required this.unitCost,
    required this.quantityOnHand,
    required this.quantityPromised,
    required this.alertLevel,
    this.supplier,
    this.lastReceivedAt,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  int get quantityFree => quantityOnHand - quantityPromised;

  bool get isLowStock => quantityOnHand <= alertLevel;

  @override
  List<Object?> get props => [
        id,
        name,
        unitId,
        unit,
        packSize,
        packPrice,
        unitCost,
        quantityOnHand,
        quantityPromised,
        alertLevel,
        supplier,
        lastReceivedAt,
        isArchived,
        createdAt,
        updatedAt,
      ];

  Material copyWith({
    int? id,
    String? name,
    int? unitId,
    String? unit,
    int? packSize,
    double? packPrice,
    double? unitCost,
    int? quantityOnHand,
    int? quantityPromised,
    int? alertLevel,
    String? supplier,
    DateTime? lastReceivedAt,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Material(
      id: id ?? this.id,
      name: name ?? this.name,
      unitId: unitId ?? this.unitId,
      unit: unit ?? this.unit,
      packSize: packSize ?? this.packSize,
      packPrice: packPrice ?? this.packPrice,
      unitCost: unitCost ?? this.unitCost,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      quantityPromised: quantityPromised ?? this.quantityPromised,
      alertLevel: alertLevel ?? this.alertLevel,
      supplier: supplier ?? this.supplier,
      lastReceivedAt: lastReceivedAt ?? this.lastReceivedAt,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
