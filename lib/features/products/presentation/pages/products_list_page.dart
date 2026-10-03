import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/usecases/calculate_bom_cost.dart';
import '../../domain/usecases/calculate_buildable_quantity.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';
import '../widgets/product_card.dart';

/// Products list page
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products',
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, size: 20),
            onPressed: () => context.push(RouteNames.channels),
          ),
        ],
      ),
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ProductsLoading || state is ProductsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductsLoaded) {
            final query = _searchController.text.toLowerCase();
            final filtered = query.isEmpty
                ? state.products
                : state.products.where((p) =>
                    p.name.toLowerCase().contains(query)).toList();

            if (state.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        color: AppColors.muted, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No products yet',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + to add your first product',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductsBloc>().add(const LoadProducts());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          'No products match "$_searchQuery"',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.muted),
                        ),
                      ),
                    ),
                  ...filtered.map(
                    (product) =>
                        _ProductCardWithAsyncData(product: product),
                  ),
                ],
              ),
            );
          }

          if (state is ProductsError) {
            return Center(
              child: Text(state.message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.alert)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: AppColors.success,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paperHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('New product',
            style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Sell price',
                prefixText: '₱ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0;

              if (name.isEmpty) {
                context.showSnackBar('Name is required', isError: true);
                return;
              }
              if (price <= 0) {
                context.showSnackBar('Price must be > 0', isError: true);
                return;
              }

              Navigator.pop(ctx);
              context.read<ProductsBloc>().add(CreateProductEvent(
                    name: name,
                    sellPrice: price,
                  ));
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

/// Wrapper that loads async data (buildable qty, material cost) per product
class _ProductCardWithAsyncData extends StatefulWidget {
  final dynamic product;

  const _ProductCardWithAsyncData({required this.product});

  @override
  State<_ProductCardWithAsyncData> createState() =>
      _ProductCardWithAsyncDataState();
}

class _ProductCardWithAsyncDataState extends State<_ProductCardWithAsyncData> {
  int? _buildableQuantity;
  double? _materialCost;

  @override
  void initState() {
    super.initState();
    _loadAsyncData();
  }

  Future<void> _loadAsyncData() async {
    final productId = widget.product.id as int;
    final calcBuildable = getIt<CalculateBuildableQuantity>();
    final calcBomCost = getIt<CalculateBomCost>();

    final bResult = await calcBuildable(productId);
    final cResult = await calcBomCost(productId);

    if (mounted) {
      setState(() {
        _buildableQuantity = bResult.fold((_) => null, (b) => b);
        _materialCost = cResult.fold((_) => null, (c) => c);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      product: widget.product,
      buildableQuantity: _buildableQuantity,
      materialCost: _materialCost,
      onTap: () async {
        final result = await context.push<bool>(
          RouteNames.productEditor
              .replaceFirst(':id', '${widget.product.id}'),
        );
        if (result == true && context.mounted) {
          context.read<ProductsBloc>().add(const LoadProducts());
        }
      },
    );
  }
}
