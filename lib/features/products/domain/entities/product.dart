import 'package:equatable/equatable.dart';

/// Product entity
class Product extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final double sellPrice;
  final bool isActive;
  final bool isStandalone;
  final int quantityOnHand;
  final int quantityPromised;
  final double unitCost;
  final int alertLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get quantityFree => quantityOnHand - quantityPromised;
  bool get isLowStock =>
      isStandalone && alertLevel > 0 && quantityOnHand <= alertLevel;

  const Product({
    this.id,
    required this.name,
    this.description,
    required this.sellPrice,
    required this.isActive,
    this.isStandalone = false,
    this.quantityOnHand = 0,
    this.quantityPromised = 0,
    this.unitCost = 0,
    this.alertLevel = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sellPrice,
        isActive,
        isStandalone,
        quantityOnHand,
        quantityPromised,
        unitCost,
        alertLevel,
        createdAt,
        updatedAt,
      ];

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? sellPrice,
    bool? isActive,
    bool? isStandalone,
    int? quantityOnHand,
    int? quantityPromised,
    double? unitCost,
    int? alertLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sellPrice: sellPrice ?? this.sellPrice,
      isActive: isActive ?? this.isActive,
      isStandalone: isStandalone ?? this.isStandalone,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      quantityPromised: quantityPromised ?? this.quantityPromised,
      unitCost: unitCost ?? this.unitCost,
      alertLevel: alertLevel ?? this.alertLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
