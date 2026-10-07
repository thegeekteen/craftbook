import 'package:equatable/equatable.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../domain/entities/product.dart';
import '../domain/product_stock_status.dart';

/// Handmade (built from a BOM) or resell (bought ready-made).
enum ProductTypeFilter {
  any,
  handmade,
  resell;

  String label(AppLocalizations l10n) => switch (this) {
        any => l10n.productsTypeAny,
        handmade => l10n.productsTypeHandmade,
        resell => l10n.productsTypeResell,
      };
}

/// Where a product's stock stands. Archived swaps the list for the
/// archived products, which are left out of every other option.
enum ProductStockFilter {
  any,
  low,
  short,
  archived;

  String label(AppLocalizations l10n) => switch (this) {
        any => l10n.productsStockAny,
        low => l10n.productsStockLow,
        short => l10n.productsStockShort,
        archived => l10n.productsStockArchived,
      };
}

/// What the Products tab's filter sheet has picked. The two groups combine,
/// e.g. handmade products that are low.
class ProductListFilter extends Equatable {
  final ProductTypeFilter type;
  final ProductStockFilter stock;

  const ProductListFilter({
    this.type = ProductTypeFilter.any,
    this.stock = ProductStockFilter.any,
  });

  static const none = ProductListFilter();

  bool get isEmpty => this == none;

  /// How many groups are set, for the Filter button's badge.
  int get activeCount =>
      (type == ProductTypeFilter.any ? 0 : 1) +
      (stock == ProductStockFilter.any ? 0 : 1);

  ProductListFilter copyWith(
          {ProductTypeFilter? type, ProductStockFilter? stock}) =>
      ProductListFilter(type: type ?? this.type, stock: stock ?? this.stock);

  @override
  List<Object?> get props => [type, stock];
}

/// The product catalogue under a search, answering what each filter would
/// show. Shared by the list and its filter sheet so their counts agree.
class ProductCatalogueView {
  /// Not archived, matching the search.
  final List<Product> listed;

  /// Archived, matching the search.
  final List<Product> archived;

  /// Whether anything is archived at all, search aside. The Archived option
  /// only shows when it is.
  final bool hasArchived;

  final Map<int, double> _available;
  final Set<int> _shortIds;

  ProductCatalogueView._(this.listed, this.archived, this.hasArchived,
      this._available, this._shortIds);

  /// [query] is matched against product names, case-insensitively.
  factory ProductCatalogueView({
    required List<Product> products,
    required Map<int, double> available,
    required Set<int> shortIds,
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    final matching = q.isEmpty
        ? products
        : products.where((p) => p.name.toLowerCase().contains(q)).toList();
    return ProductCatalogueView._(
      matching.where((p) => !p.isArchived).toList(),
      matching.where((p) => p.isArchived).toList(),
      products.any((p) => p.isArchived),
      available,
      shortIds,
    );
  }

  bool isLow(Product p) => isProductLow(p, _available[p.id]);
  bool isShort(Product p) => _shortIds.contains(p.id);

  /// Whether anything listed is short. The Short option only shows when it is.
  bool get hasShort => listed.any(isShort);

  /// [filter] with any option that has nothing behind it dropped, so a
  /// filter on Short or Archived never strands the user once it empties.
  ProductListFilter effective(ProductListFilter filter) {
    final gone = (filter.stock == ProductStockFilter.short && !hasShort) ||
        (filter.stock == ProductStockFilter.archived && !hasArchived);
    return gone ? filter.copyWith(stock: ProductStockFilter.any) : filter;
  }

  /// The products [filter] shows, problems first, then by name.
  List<Product> apply(ProductListFilter filter) {
    final base =
        filter.stock == ProductStockFilter.archived ? archived : listed;
    bool passes(Product p) {
      final typeOk = switch (filter.type) {
        ProductTypeFilter.any => true,
        ProductTypeFilter.handmade => !p.isStandalone,
        ProductTypeFilter.resell => p.isStandalone,
      };
      final stockOk = switch (filter.stock) {
        ProductStockFilter.any || ProductStockFilter.archived => true,
        ProductStockFilter.low => isLow(p),
        ProductStockFilter.short => isShort(p),
      };
      return typeOk && stockOk;
    }

    return base.where(passes).toList()
      ..sort((a, b) {
        if (isShort(a) != isShort(b)) return isShort(a) ? -1 : 1;
        if (isLow(a) != isLow(b)) return isLow(a) ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
  }

  /// How many products [filter] shows.
  int count(ProductListFilter filter) => apply(filter).length;
}
