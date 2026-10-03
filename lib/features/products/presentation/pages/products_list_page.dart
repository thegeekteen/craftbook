import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state.dart';
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

class _ProductsListView extends StatefulWidget {
  const _ProductsListView();

  @override
  State<_ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<_ProductsListView> {
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
                  ProductsError(:final message) =>
                    Center(child: ErrorState(message: message, onRetry: _reload)),
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
    final visible = state.products
        .where((p) => _query.isEmpty || p.name.toLowerCase().contains(_query))
        .toList()
      // Active products first, then by name.
      ..sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    if (visible.isEmpty) {
      return ListView(children: [
        state.products.isEmpty
            ? EmptyState(
                icon: Icons.sell_outlined,
                title: 'No products yet',
                message: 'Add what you sell and the materials one piece uses.',
                actionLabel: 'Add product',
                onAction: () => _open(RouteNames.newProduct),
              )
            : EmptyState(icon: Icons.search_off_rounded, title: 'No matches', message: 'Nothing matches "$_query".'),
      ]);
    }

    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, AppSpacing.fabClearance),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final p = visible[i];
          return ProductCard(
            product: p,
            unitCost: state.unitCosts[p.id],
            available: state.available[p.id],
            onTap: () => _open(RouteNames.productPath(p.id!)),
          );
        },
      ),
    );
  }
}
