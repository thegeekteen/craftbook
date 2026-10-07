import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_controls.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_state.dart';
import '../product_list_filter.dart';
import 'product_actions.dart';
import 'product_card.dart';

/// The Products tab of Inventory: the product list with cost, margin
/// and availability. The page owns the search and filter so its app bar
/// can open the filter sheet; this draws the list and the active chips.
class ProductsTab extends StatefulWidget {
  final TextEditingController search;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ProductListFilter filter;
  final ValueChanged<ProductListFilter> onFilterChanged;

  /// Pushes [location] and reloads when it reports a change.
  final Future<void> Function(String location) onOpen;

  /// Reloads the catalogue, e.g. after a long-press action.
  final VoidCallback onReload;

  const ProductsTab({
    super.key,
    required this.search,
    required this.query,
    required this.onQueryChanged,
    required this.filter,
    required this.onFilterChanged,
    required this.onOpen,
    required this.onReload,
  });

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab>
    with AutomaticKeepAliveClientMixin {
  // Keeps the scroll position while the Materials tab is showing.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: AppSearchField(
            hint: context.l10n.productsSearchHint,
            controller: widget.search,
            onChanged: widget.onQueryChanged,
          ),
        ),
        Expanded(
          child: BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) {
              return switch (state) {
                ProductsLoaded() => _buildList(state),
                ProductsError(:final message) => Center(
                    child:
                        ErrorState(message: message, onRetry: widget.onReload)),
                _ => const Center(child: CircularProgressIndicator()),
              };
            },
          ),
        ),
      ],
    );
  }

  Widget _buildList(ProductsLoaded state) {
    final view = ProductCatalogueView(
      products: state.products,
      available: state.available,
      shortIds: state.shortIds,
      query: widget.query,
    );
    final filter = view.effective(widget.filter);
    final visible = view.apply(filter);

    return Column(
      children: [
        ActiveFilterChips(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          filters: [
            if (filter.type != ProductTypeFilter.any)
              (
                filter.type.label(context.l10n),
                () => widget.onFilterChanged(
                    filter.copyWith(type: ProductTypeFilter.any)),
              ),
            if (filter.stock != ProductStockFilter.any)
              (
                filter.stock.label(context.l10n),
                () => widget.onFilterChanged(
                    filter.copyWith(stock: ProductStockFilter.any)),
              ),
          ],
          onClearAll: () => widget.onFilterChanged(ProductListFilter.none),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onReload(),
            child: visible.isEmpty
                ? ListView(children: [_empty(state, filter)])
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        16, 4, 16, AppSpacing.fabClearance),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final p = visible[i];
                      return ProductCard(
                        product: p,
                        unitCost: state.unitCosts[p.id],
                        available: state.available[p.id],
                        isShort: view.isShort(p),
                        onTap: () =>
                            widget.onOpen(RouteNames.productPath(p.id!)),
                        onLongPress: () async {
                          if (await ProductActions.open(context, p) &&
                              mounted) {
                            widget.onReload();
                          }
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _empty(ProductsLoaded state, ProductListFilter filter) {
    final l10n = context.l10n;
    if (state.products.isEmpty) {
      return EmptyState(
        icon: Icons.sell_outlined,
        title: l10n.productsEmptyTitle,
        message: l10n.productsEmptyMessage,
        actionLabel: l10n.productsAddProduct,
        onAction: () => widget.onOpen(RouteNames.newProduct),
      );
    }
    if (widget.query.trim().isNotEmpty) {
      return EmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.productsNoMatches,
          message: l10n.productsNoMatchesFor(widget.query.trim()));
    }
    if (filter.activeCount > 1) {
      return EmptyState(
        icon: Icons.filter_list_off_rounded,
        title: l10n.productsNoFilterMatchTitle,
        message: l10n.productsNoFilterMatchMessage,
      );
    }
    return switch ((filter.type, filter.stock)) {
      (ProductTypeFilter.handmade, _) => EmptyState(
          icon: Icons.content_cut_rounded,
          title: l10n.productsNoHandmadeTitle,
          message: l10n.productsNoHandmadeMessage,
        ),
      (ProductTypeFilter.resell, _) => EmptyState(
          icon: Icons.inventory_2_outlined,
          title: l10n.productsNoResellTitle,
          message: l10n.productsNoResellMessage,
        ),
      (_, ProductStockFilter.any) => EmptyState(
          icon: Icons.archive_outlined,
          title: l10n.productsAllArchivedTitle,
          message: l10n.productsAllArchivedMessage,
        ),
      _ => EmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: l10n.productsNothingLowTitle,
          message: l10n.productsNothingLowMessage,
        ),
    };
  }
}
