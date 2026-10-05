import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Product entity
class Product extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final double sellPrice;

  /// What this is sold and counted in.
  final int unitId;

  /// The unit's label, looked up with it. Rendered as typed, never pluralised.
  final String unit;

  /// Kept for past orders but left out of lists, pickers and alerts.
  final bool isArchived;
  final bool isStandalone;
  final int quantityOnHand;
  final int quantityPromised;
  final double unitCost;
  final int alertLevel;

  /// Encoded image bytes (JPEG/PNG), or null when no photo is set.
  final Uint8List? photo;
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
    this.unitId = AppConstants.defaultUnitId,
    this.unit = AppConstants.defaultUnitLabel,
    this.isArchived = false,
    this.isStandalone = false,
    this.quantityOnHand = 0,
    this.quantityPromised = 0,
    this.unitCost = 0,
    this.alertLevel = 0,
    this.photo,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sellPrice,
        unitId,
        unit,
        isArchived,
        isStandalone,
        quantityOnHand,
        quantityPromised,
        unitCost,
        alertLevel,
        photo,
        createdAt,
        updatedAt,
      ];

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? sellPrice,
    int? unitId,
    String? unit,
    bool? isArchived,
    bool? isStandalone,
    int? quantityOnHand,
    int? quantityPromised,
    double? unitCost,
    int? alertLevel,
    Uint8List? photo,
    bool clearPhoto = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sellPrice: sellPrice ?? this.sellPrice,
      unitId: unitId ?? this.unitId,
      unit: unit ?? this.unit,
      isArchived: isArchived ?? this.isArchived,
      isStandalone: isStandalone ?? this.isStandalone,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      quantityPromised: quantityPromised ?? this.quantityPromised,
      unitCost: unitCost ?? this.unitCost,
      alertLevel: alertLevel ?? this.alertLevel,
      photo: clearPhoto ? null : (photo ?? this.photo),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
