import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/presentation/product_list_filter.dart';
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime(2026, 1, 1);

Product _product(int id, String name,
        {bool resell = false,
        bool archived = false,
        double onHand = 0,
        double alert = 0}) =>
    Product(
      id: id,
      name: name,
      sellPrice: 100,
      isStandalone: resell,
      isArchived: archived,
      quantityOnHand: onHand,
      alertLevel: alert,
      createdAt: _at,
      updatedAt: _at,
    );

void main() {
  // Tulip: handmade, can build 2, warns at 3 -> low.
  // Strap: handmade, no alert, short for orders.
  // Gift box: resell, 1 on hand, warns at 3 -> low.
  // Vase: resell, plenty. Old card: archived handmade. Old tin: archived resell.
  final products = [
    _product(1, 'Tulip', alert: 3),
    _product(2, 'Strap'),
    _product(3, 'Gift box', resell: true, onHand: 1, alert: 3),
    _product(4, 'Vase', resell: true, onHand: 10, alert: 2),
    _product(5, 'Old card', archived: true),
    _product(6, 'Old tin', resell: true, archived: true),
  ];
  ProductCatalogueView view({String query = '', Set<int> short = const {2}}) =>
      ProductCatalogueView(
        products: products,
        available: const {1: 2, 2: 5, 5: 0},
        shortIds: short,
        query: query,
      );
  List<String> names(List<Product> ps) => ps.map((p) => p.name).toList();

  group('ProductListFilter', () {
    test('counts each group that is set', () {
      expect(ProductListFilter.none.activeCount, 0);
      expect(ProductListFilter.none.isEmpty, isTrue);
      const both = ProductListFilter(
          type: ProductTypeFilter.resell, stock: ProductStockFilter.low);
      expect(both.activeCount, 2);
      expect(both.copyWith(type: ProductTypeFilter.any).activeCount, 1);
    });
  });

  group('ProductCatalogueView', () {
    test('leaves archived out and puts problems first', () {
      expect(names(view().apply(ProductListFilter.none)),
          ['Strap', 'Gift box', 'Tulip', 'Vase']);
    });

    test('filters by type', () {
      expect(
          names(view().apply(
              const ProductListFilter(type: ProductTypeFilter.handmade))),
          ['Strap', 'Tulip']);
      expect(
          names(view()
              .apply(const ProductListFilter(type: ProductTypeFilter.resell))),
          ['Gift box', 'Vase']);
    });

    test('combines type and stock', () {
      const lowResell = ProductListFilter(
          type: ProductTypeFilter.resell, stock: ProductStockFilter.low);
      expect(names(view().apply(lowResell)), ['Gift box']);
      expect(view().count(lowResell), 1);
    });

    test('Archived swaps in the archived products and keeps the type', () {
      const archived = ProductListFilter(stock: ProductStockFilter.archived);
      expect(names(view().apply(archived)), ['Old card', 'Old tin']);
      expect(
          names(view()
              .apply(archived.copyWith(type: ProductTypeFilter.handmade))),
          ['Old card']);
    });

    test('search narrows the list and the counts', () {
      final v = view(query: 'GIFT');
      expect(names(v.apply(ProductListFilter.none)), ['Gift box']);
      expect(v.count(const ProductListFilter(type: ProductTypeFilter.handmade)),
          0);
    });

    test('drops Short or Archived once nothing is behind them', () {
      const short = ProductListFilter(
          type: ProductTypeFilter.handmade, stock: ProductStockFilter.short);
      expect(view().effective(short), short);
      expect(view(short: const {}).effective(short),
          const ProductListFilter(type: ProductTypeFilter.handmade));

      final none = ProductCatalogueView(
        products: products.where((p) => !p.isArchived).toList(),
        available: const {},
        shortIds: const {},
      );
      expect(none.hasArchived, isFalse);
      expect(
          none.effective(
              const ProductListFilter(stock: ProductStockFilter.archived)),
          ProductListFilter.none);
    });
  });
}
