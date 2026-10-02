import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/usecases/calculate_buildable_quantity.dart';
import '../../../products/domain/usecases/get_products.dart';
import '../../domain/entities/order_item.dart';

/// Bottom sheet for picking products to add to an order
class ProductPickerSheet extends StatefulWidget {
  final void Function(OrderItemInput item) onSelected;
  final List<int> addedProductIds;

  const ProductPickerSheet({
    super.key,
    required this.onSelected,
    this.addedProductIds = const [],
  });

  @override
  State<ProductPickerSheet> createState() => _ProductPickerSheetState();

  static Future<void> show(
    BuildContext context, {
    required void Function(OrderItemInput item) onSelected,
    List<int> addedProductIds = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.paperHigh,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ProductPickerSheet(
            onSelected: (item) {
              Navigator.pop(context);
              onSelected(item);
            },
            addedProductIds: addedProductIds,
          ),
        ),
      ),
    );
  }
}

class _ProductPickerSheetState extends State<ProductPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<Product> _products = [];
  Map<int, int> _buildableQuantities = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final getProducts = getIt<GetProducts>();
    final calcBuildable = getIt<CalculateBuildableQuantity>();

    final result = await getProducts(activeOnly: true);
    final products = result.fold((_) => <Product>[], (p) => p);

    final buildable = <int, int>{};
    for (final product in products) {
      final bResult = await calcBuildable(product.id!);
      buildable[product.id!] = bResult.fold((_) => 0, (b) => b);
    }

    if (mounted) {
      setState(() {
        _products = products;
        _buildableQuantities = buildable;
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.hair,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Add product',
            style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
          ),
        ),

        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon:
                  const Icon(Icons.search, size: 18, color: AppColors.muted),
              hintStyle: AppTextStyles.bodySmall,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Product list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No products found',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.muted),
                      ),
                    )
                  : ListView.builder(
                      controller:
                          ScrollController(), // inner scroll in DraggableScrollableSheet
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isAdded =
                            widget.addedProductIds.contains(product.id);
                        final buildable =
                            _buildableQuantities[product.id!] ?? 0;
                        final isLow = buildable > 0 && buildable < 5;

                        return ListTile(
                          title: Text(
                            product.name,
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.ink),
                          ),
                          subtitle: Row(
                            children: [
                              CurrencyText(
                                amount: product.sellPrice,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.coin),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Buildable: $buildable',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLow)
                                const StatusPill(
                                  text: 'LOW',
                                  type: StatusPillType.warning,
                                ),
                              if (isAdded) ...[
                                const SizedBox(width: 4),
                                const StatusPill(
                                  text: 'ADDED',
                                  type: StatusPillType.success,
                                ),
                              ],
                            ],
                          ),
                          enabled: buildable > 0,
                          onTap: buildable > 0
                              ? () {
                                  widget.onSelected(OrderItemInput(
                                    productId: product.id!,
                                    productName: product.name,
                                    quantity: 1,
                                    unitPrice: product.sellPrice,
                                  ));
                                }
                              : null,
                        );
                      },
                    ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
