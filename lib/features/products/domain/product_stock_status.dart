import 'entities/product.dart';

/// Whether a product is at or below the alert level the user set.
///
/// Resell products compare pieces on hand; handmade products compare how
/// many their materials can still build. An alert level of 0 means off.
bool isProductLow(Product p, int? buildable) {
  if (p.isStandalone) return p.isLowStock;
  return p.alertLevel > 0 && buildable != null && buildable <= p.alertLevel;
}

/// Whether open orders want more than the product's stock can cover.
///
/// [rawBuildable] must be the unclamped value: it goes negative when
/// reservations exceed what's on hand. Resell reserves its own pieces, so
/// negative free stock is enough. Handmade shares materials with other
/// products, so it only counts as short when it has pending orders itself.
bool isProductShort(
  Product p, {
  required int rawBuildable,
  required int pendingOrders,
}) {
  if (p.isStandalone) return p.quantityFree < 0;
  return pendingOrders > 0 && rawBuildable < 0;
}
