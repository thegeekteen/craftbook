import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/quantity.dart';

class BomItem extends Equatable {
  final int? id;
  final int productId;
  final int materialId;
  final String materialName;

  /// The material's unit label, looked up with its name and cost. [makes] is
  /// counted in the product's own unit instead.
  final String materialUnit;
  final double materialUnitCost;
  final double quantityRequired;

  /// How many products [quantityRequired] pieces make, e.g. one A4 sheet
  /// makes 9 business cards. 1 means one product uses them all.
  final double makes;
  final DateTime createdAt;

  const BomItem({
    this.id,
    required this.productId,
    required this.materialId,
    required this.materialName,
    this.materialUnit = AppConstants.defaultUnitLabel,
    required this.materialUnitCost,
    required this.quantityRequired,
    this.makes = 1,
    required this.createdAt,
  });

  /// Material cost of one product: a sheet that makes 9 costs a ninth each.
  double get lineCost => quantityRequired * materialUnitCost / makes;

  /// How much of the material [products] products take, exactly. Stock is
  /// fractional now, so a card reserves a ninth of a sheet rather than a
  /// whole one; rounded to the precision quantities are kept at.
  double piecesFor(double products) => qty(quantityRequired * products / makes);

  @override
  List<Object?> get props => [
        id,
        productId,
        materialId,
        materialName,
        materialUnit,
        materialUnitCost,
        quantityRequired,
        makes,
        createdAt,
      ];
}
