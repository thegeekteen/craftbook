import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Product entity
class Product extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final double sellPrice;

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
