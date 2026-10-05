import 'package:equatable/equatable.dart';

class BomItem extends Equatable {
  final int? id;
  final int productId;
  final int materialId;
  final String materialName;
  final double materialUnitCost;
  final int quantityRequired;

  /// How many products [quantityRequired] pieces make, e.g. one A4 sheet
  /// makes 9 business cards. 1 means one product uses them all.
  final int makes;
  final DateTime createdAt;

  const BomItem({
    this.id,
    required this.productId,
    required this.materialId,
    required this.materialName,
    required this.materialUnitCost,
    required this.quantityRequired,
    this.makes = 1,
    required this.createdAt,
  });

  /// Material cost of one product: a sheet that makes 9 costs a ninth each.
  double get lineCost => quantityRequired * materialUnitCost / makes;

  /// Whole pieces of material needed for [products] products. Stock is
  /// counted in whole pieces, so a part-used sheet counts as one.
  int piecesFor(int products) =>
      (quantityRequired * products + makes - 1) ~/ makes;

  @override
  List<Object?> get props => [
        id,
        productId,
        materialId,
        materialName,
        materialUnitCost,
        quantityRequired,
        makes,
        createdAt,
      ];
}
