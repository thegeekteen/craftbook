import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/filter_controls.dart';
import '../../../stock/domain/usecases/get_buy_list.dart';
import '../../../stock/presentation/bloc/materials_bloc.dart';
import '../../../stock/presentation/bloc/materials_event.dart';
import '../../../stock/presentation/bloc/materials_state.dart';
import '../../../stock/presentation/material_list_filter.dart';
import '../../../stock/presentation/widgets/buy_list_button.dart';
import '../../../stock/presentation/widgets/materials_filter_sheet.dart';
import '../../../stock/presentation/widgets/materials_tab.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';
import '../product_list_filter.dart';
import '../widgets/products_filter_sheet.dart';
import '../widgets/products_tab.dart';

/// Which tab of the inventory is showing.
enum InventoryTab {
  products,
  materials;

  /// Reads the `tab` query parameter; anything unknown means Products.
  static InventoryTab parse(String? value) =>
      value == materials.name ? materials : products;
}

/// The Inventory bottom-nav tab: what you sell and what it's made from,
/// side by side, so materials are one tap away instead of under More.
class InventoryPage extends StatelessWidget {
  final InventoryTab initialTab;

  const InventoryPage({super.key, this.initialTab = InventoryTab.products});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => getIt<ProductsBloc>()..add(const LoadProducts())),
        BlocProvider(
            create: (_) => getIt<MaterialsBloc>()..add(const LoadMaterials())),
      ],
      child: _InventoryView(initialTab: initialTab),
    );
  }
}

class _InventoryView extends StatefulWidget {
  final InventoryTab initialTab;

  const _InventoryView({required this.initialTab});

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: InventoryTab.values.length,
    initialIndex: widget.initialTab.index,
    vsync: this,
  )..addListener(_onTabChanged);

  final _productSearch = TextEditingController();
  final _materialSearch = TextEditingController();
  String _productQuery = '';
  String _materialQuery = '';
  ProductListFilter _productFilter = ProductListFilter.none;
  MaterialStockFilter _materialFilter = MaterialStockFilter.any;

  /// Items on the buy list, products and materials, for the app-bar shortcut.
  int _toBuy = 0;

  InventoryTab get _tab => InventoryTab.values[_tabs.index];

  @override
  void initState() {
    super.initState();
    _loadBuyCount();
  }

  @override
  void didUpdateWidget(_InventoryView old) {
    super.didUpdateWidget(old);
    // Going to /materials while the page is up lands on its tab.
    if (widget.initialTab != old.initialTab) {
      _tabs.animateTo(widget.initialTab.index);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    _productSearch.dispose();
    _materialSearch.dispose();
    super.dispose();
  }

  // Redraws the app bar's filter badge and the FAB for the new tab.
  void _onTabChanged() {
    if (!_tabs.indexIsChanging) setState(() {});
  }

  /// A failed count just leaves the shortcut without a number.
  Future<void> _loadBuyCount() async {
    final result = await getIt<GetBuyList>()();
    if (!mounted) return;
    if (result case Success(:final value)) {
      setState(() => _toBuy = value.length);
    }
  }

  /// Reloads both tabs: a change to a product can move material stock and
  /// the other way round.
  void _reload() {
    context.read<ProductsBloc>().add(const LoadProducts());
    context.read<MaterialsBloc>().add(const LoadMaterials());
    _loadBuyCount();
  }

  Future<void> _open(String location) async {
    final changed = await context.push<bool>(location);
    if (changed == true && mounted) _reload();
  }

  ProductCatalogueView? _productView(ProductsState state) =>
      state is ProductsLoaded
          ? ProductCatalogueView(
              products: state.products,
              available: state.available,
              shortIds: state.shortIds,
              query: _productQuery,
            )
          : null;

  MaterialCatalogueView? _materialView(MaterialsState state) => state
          is MaterialsLoaded
      ? MaterialCatalogueView(materials: state.materials, query: _materialQuery)
      : null;

  Future<void> _openFilter() async {
    switch (_tab) {
      case InventoryTab.products:
        final view = _productView(context.read<ProductsBloc>().state);
        if (view == null) return;
        final picked = await showProductsFilterSheet(context,
            current: view.effective(_productFilter), view: view);
        if (picked != null && mounted) {
          setState(() => _productFilter = picked);
        }
      case InventoryTab.materials:
        final view = _materialView(context.read<MaterialsBloc>().state);
        if (view == null) return;
        final picked = await showMaterialsFilterSheet(context,
            current: view.effective(_materialFilter), view: view);
        if (picked != null && mounted) {
          setState(() => _materialFilter = picked);
        }
    }
  }

  /// The badge counts what the list actually applies, so a Short or
  /// Archived filter that emptied out doesn't leave a stale number.
  Widget _filterButton() {
    return switch (_tab) {
      InventoryTab.products => BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) => FilterButton(
            activeCount: (_productView(state)?.effective(_productFilter) ??
                    _productFilter)
                .activeCount,
            onPressed: _openFilter,
          ),
        ),
      InventoryTab.materials => BlocBuilder<MaterialsBloc, MaterialsState>(
          builder: (context, state) {
            final filter = _materialView(state)?.effective(_materialFilter) ??
                _materialFilter;
            return FilterButton(
              activeCount: filter == MaterialStockFilter.any ? 0 : 1,
              onPressed: _openFilter,
            );
          },
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final onProducts = _tab == InventoryTab.products;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.productsInventoryTitle),
        actions: [
          _filterButton(),
          BuyListButton(
              lowCount: _toBuy, onPressed: () => _open(RouteNames.buyList)),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                final view = _productView(state);
                return _CountedTab(
                  label: context.l10n.productsTabProducts,
                  count: view?.count(view.effective(_productFilter)),
                  selected: _tab == InventoryTab.products,
                );
              },
            ),
            BlocBuilder<MaterialsBloc, MaterialsState>(
              builder: (context, state) {
                final view = _materialView(state);
                return _CountedTab(
                  label: context.l10n.productsTabMaterials,
                  count: view?.count(view.effective(_materialFilter)),
                  selected: _tab == InventoryTab.materials,
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          ProductsTab(
            search: _productSearch,
            query: _productQuery,
            onQueryChanged: (v) => setState(() => _productQuery = v),
            filter: _productFilter,
            onFilterChanged: (f) => setState(() => _productFilter = f),
            onOpen: _open,
            onReload: _reload,
          ),
          MaterialsTab(
            search: _materialSearch,
            query: _materialQuery,
            onQueryChanged: (v) => setState(() => _materialQuery = v),
            filter: _materialFilter,
            onFilterChanged: (f) => setState(() => _materialFilter = f),
            onOpen: _open,
            onReload: _reload,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _open(onProducts ? RouteNames.newProduct : RouteNames.newMaterial),
        icon: const Icon(Icons.add_rounded),
        label: Text(onProducts
            ? context.l10n.productsFabProduct
            : context.l10n.productsFabMaterial),
      ),
    );
  }
}

/// A tab label with a pill counting what the tab shows under its search
/// and filter, so a narrowed list says so before you switch to it. The
/// selected tab's pill takes the accent, like its underline.
class _CountedTab extends StatelessWidget {
  final String label;

  /// Null while the tab is still loading.
  final int? count;

  final bool selected;

  const _CountedTab(
      {required this.label, required this.count, required this.selected});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null) ...[
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? c.goSoft : c.hair,
                borderRadius: AppRadii.pillAll,
              ),
              child: Text(
                '$count',
                style: AppTextStyles.monoTag.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? c.go : c.muted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
