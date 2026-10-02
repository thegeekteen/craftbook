import 'package:equatable/equatable.dart';

/// Material entity
class Material extends Equatable {
  final int? id;
  final String name;
  final int packSize;
  final double packPrice;
  final double unitCost;
  final int quantityOnHand;
  final int quantityPromised;
  final int alertLevel;
  final String? supplier;
  final DateTime? lastReceivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Material({
    this.id,
    required this.name,
    required this.packSize,
    required this.packPrice,
    required this.unitCost,
    required this.quantityOnHand,
    required this.quantityPromised,
    required this.alertLevel,
    this.supplier,
    this.lastReceivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  int get quantityFree => quantityOnHand - quantityPromised;

  bool get isLowStock => quantityOnHand <= alertLevel;

  @override
  List<Object?> get props => [
        id,
        name,
        packSize,
        packPrice,
        unitCost,
        quantityOnHand,
        quantityPromised,
        alertLevel,
        supplier,
        lastReceivedAt,
        createdAt,
        updatedAt,
      ];

  Material copyWith({
    int? id,
    String? name,
    int? packSize,
    double? packPrice,
    double? unitCost,
    int? quantityOnHand,
    int? quantityPromised,
    int? alertLevel,
    String? supplier,
    DateTime? lastReceivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Material(
      id: id ?? this.id,
      name: name ?? this.name,
      packSize: packSize ?? this.packSize,
      packPrice: packPrice ?? this.packPrice,
      unitCost: unitCost ?? this.unitCost,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      quantityPromised: quantityPromised ?? this.quantityPromised,
      alertLevel: alertLevel ?? this.alertLevel,
      supplier: supplier ?? this.supplier,
      lastReceivedAt: lastReceivedAt ?? this.lastReceivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
