import 'package:equatable/equatable.dart';

class BuyListItem extends Equatable {
  final int materialId;
  final String materialName;
  final int quantityOnHand;
  final int quantityPromised;
  final int alertLevel;
  final int packSize;
  final double packPrice;
  final int packsToOrder;
  final List<BlockedProduct> blockedProducts;

  const BuyListItem({
    required this.materialId,
    required this.materialName,
    required this.quantityOnHand,
    required this.quantityPromised,
    required this.alertLevel,
    required this.packSize,
    required this.packPrice,
    required this.packsToOrder,
    required this.blockedProducts,
  });

  int get quantityFree => quantityOnHand - quantityPromised;
  double get totalCost => packsToOrder * packPrice;
  bool get isCritical => quantityFree <= 0;

  @override
  List<Object?> get props => [
        materialId,
        materialName,
        quantityOnHand,
        quantityPromised,
        alertLevel,
        packSize,
        packPrice,
        packsToOrder,
        blockedProducts,
      ];
}

class BlockedProduct extends Equatable {
  final int productId;
  final String productName;
  final int buildableQuantity;
  final int openOrderCount;

  const BlockedProduct({
    required this.productId,
    required this.productName,
    required this.buildableQuantity,
    required this.openOrderCount,
  });

  @override
  List<Object?> get props =>
      [productId, productName, buildableQuantity, openOrderCount];
}
