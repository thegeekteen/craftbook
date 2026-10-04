import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/product.dart';
import '../../domain/product_stock_status.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';
import '../widgets/product_card.dart';

/// The product catalogue with cost, margin and availability.
class ProductsListPage extends StatelessWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductsBloc>()..add(const LoadProducts()),
      child: const _ProductsListView(),
    );
  }
}

enum _ProductFilter { all, handmade, resell, low, short }

class _ProductsListView extends StatefulWidget {
  const _ProductsListView();

  @override
  State<_ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<_ProductsListView> {
  _ProductFilter _filter = _ProductFilter.all;
  String _query = '';

  void _reload() => context.read<ProductsBloc>().add(const LoadProducts());

  Future<void> _open(String location) async {
    final changed = await context.push<bool>(location);
    if (changed == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: AppSearchField(
              hint: 'Search products',
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                return switch (state) {
                  ProductsLoaded() => _buildList(state),
                  ProductsError(:final message) => Center(
                      child: ErrorState(message: message, onRetry: _reload)),
                  _ => const Center(child: CircularProgressIndicator()),
                };
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(RouteNames.newProduct),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Product'),
      ),
    );
  }

  Widget _buildList(ProductsLoaded state) {
    final searched = _query.isEmpty
        ? state.products
        : state.products
            .where((p) => p.name.toLowerCase().contains(_query))
            .toList();
    bool isLow(Product p) => isProductLow(p, state.available[p.id]);
    bool isShort(Product p) => state.shortIds.contains(p.id);
    final shortCount = searched.where(isShort).length;
    // The Short chip hides when nothing is short; don't strand the user on it.
    final filter = _filter == _ProductFilter.short && shortCount == 0
        ? _ProductFilter.all
        : _filter;
    bool passes(Product p) => switch (filter) {
          _ProductFilter.all => true,
          _ProductFilter.handmade => !p.isStandalone,
          _ProductFilter.resell => p.isStandalone,
          _ProductFilter.low => isLow(p),
          _ProductFilter.short => isShort(p),
        };
    final visible = searched.where(passes).toList()
      // Problems first, then active before hidden, then by name.
      ..sort((a, b) {
        if (isShort(a) != isShort(b)) return isShort(a) ? -1 : 1;
        if (isLow(a) != isLow(b)) return isLow(a) ? -1 : 1;
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Column(
      children: [
        if (state.products.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ChoiceChipRow<_ProductFilter>.single(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              selected: filter,
              onSelected: (f) => setState(() => _filter = f),
              options: [
                ChipOption(_ProductFilter.all, 'All', count: searched.length),
                ChipOption(_ProductFilter.handmade, 'Handmade',
                    count: searched.where((p) => !p.isStandalone).length),
                ChipOption(_ProductFilter.resell, 'Resell',
                    count: searched.where((p) => p.isStandalone).length),
                ChipOption(_ProductFilter.low, 'Low',
                    count: searched.where(isLow).length),
                if (shortCount > 0)
                  ChipOption(_ProductFilter.short, 'Short', count: shortCount),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
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
                        isShort: isShort(p),
                        onTap: () => _open(RouteNames.productPath(p.id!)),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _empty(ProductsLoaded state, _ProductFilter filter) {
    if (state.products.isEmpty) {
      return EmptyState(
        icon: Icons.sell_outlined,
        title: 'No products yet',
        message: 'Add what you sell and the materials one piece uses.',
        actionLabel: 'Add product',
        onAction: () => _open(RouteNames.newProduct),
      );
    }
    if (_query.isNotEmpty) {
      return EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No matches',
          message: 'Nothing matches "$_query".');
    }
    return switch (filter) {
      _ProductFilter.handmade => const EmptyState(
          icon: Icons.content_cut_rounded,
          title: 'No handmade products',
          message: 'Products made from your materials show up here.',
        ),
      _ProductFilter.resell => const EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'No resell products',
          message: 'Things you buy ready-made and sell on show up here.',
        ),
      _ => const EmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'Nothing is low',
          message: 'Set a warning level on a product to watch it here.',
        ),
    };
  }
}
