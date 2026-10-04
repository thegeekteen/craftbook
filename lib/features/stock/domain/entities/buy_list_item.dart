import 'package:equatable/equatable.dart';

/// What a buy-list line restocks.
enum BuyListKind { material, product }

/// One thing to buy: a low material, or a low resell product.
///
/// Resell products are bought by the piece, so they carry a pack size of 1
/// and their unit cost as the pack price.
class BuyListItem extends Equatable {
  final BuyListKind kind;

  /// Material id or product id, depending on [kind].
  final int id;
  final String name;
  final int quantityOnHand;
  final int quantityPromised;
  final int alertLevel;
  final int packSize;
  final double packPrice;
  final int packsToOrder;
  final List<BlockedProduct> blockedProducts;

  /// Pending orders for a resell product itself. Materials use
  /// [blockedProducts] instead.
  final int ownOpenOrders;

  const BuyListItem({
    this.kind = BuyListKind.material,
    required this.id,
    required this.name,
    required this.quantityOnHand,
    required this.quantityPromised,
    required this.alertLevel,
    required this.packSize,
    required this.packPrice,
    required this.packsToOrder,
    required this.blockedProducts,
    this.ownOpenOrders = 0,
  });

  /// Open orders waiting on this item.
  int get blockingOrders => kind == BuyListKind.product
      ? ownOpenOrders
      : blockedProducts.fold(0, (s, p) => s + p.openOrderCount);

  int get quantityFree => quantityOnHand - quantityPromised;
  double get totalCost => packsToOrder * packPrice;
  bool get isCritical => quantityFree <= 0;

  @override
  List<Object?> get props => [
        kind,
        id,
        name,
        quantityOnHand,
        quantityPromised,
        alertLevel,
        packSize,
        packPrice,
        packsToOrder,
        blockedProducts,
        ownOpenOrders,
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
