import 'package:equatable/equatable.dart';

class BomItem extends Equatable {
  final int? id;
  final int productId;
  final int materialId;
  final String materialName;
  final double materialUnitCost;
  final int quantityRequired;
  final DateTime createdAt;

  const BomItem({
    this.id,
    required this.productId,
    required this.materialId,
    required this.materialName,
    required this.materialUnitCost,
    required this.quantityRequired,
    required this.createdAt,
  });

  double get lineCost => quantityRequired * materialUnitCost;

  @override
  List<Object?> get props => [
        id,
        productId,
        materialId,
        materialName,
        materialUnitCost,
        quantityRequired,
        createdAt,
      ];
}
