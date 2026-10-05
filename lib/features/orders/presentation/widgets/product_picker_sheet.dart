import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/product_photo.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/product_stock_status.dart';
import '../../../products/domain/usecases/calculate_buildable_quantity.dart';
import '../../../products/domain/usecases/get_products.dart';
import '../../domain/entities/order_item.dart';

/// Bottom sheet for picking a product to add to an order. Shows how many
/// can be built (or are in stock) and disables products that can't be made.
class ProductPickerSheet extends StatefulWidget {
  final void Function(OrderItemInput item) onSelected;
  final List<int> addedProductIds;
  final ScrollController? scrollController;

  const ProductPickerSheet({
    super.key,
    required this.onSelected,
    this.addedProductIds = const [],
    this.scrollController,
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
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ProductPickerSheet(
          scrollController: scrollController,
          onSelected: (item) {
            Navigator.pop(sheetContext);
            onSelected(item);
          },
          addedProductIds: addedProductIds,
        ),
      ),
    );
  }
}

class _ProductPickerSheetState extends State<ProductPickerSheet> {
  String _query = '';
  List<Product> _products = [];
  Map<int, double> _buildable = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<GetProducts>()(includeArchived: false);
    switch (result) {
      case Error(:final failure):
        if (mounted) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        }
        return;
      case Success(:final value):
        final calc = getIt<CalculateBuildableQuantity>();
        final buildable = <int, double>{};
        for (final p in value) {
          final r = await calc(p.id!);
          buildable[p.id!] = switch (r) {
            Success(:final value) => value < 0 ? 0 : value,
            Error() => 0,
          };
        }
        if (!mounted) return;
        // Buildable products first, then alphabetical.
        value.sort((a, b) {
          final byStock = ((buildable[b.id] ?? 0) > 0 ? 1 : 0) -
              ((buildable[a.id] ?? 0) > 0 ? 1 : 0);
          return byStock != 0 ? byStock : a.name.compareTo(b.name);
        });
        setState(() {
          _products = value;
          _buildable = buildable;
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final visible = _query.isEmpty
        ? _products
        : _products
            .where((p) => p.name.toLowerCase().contains(_query))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add product',
                  style: AppTextStyles.displaySmall.copyWith(color: c.ink)),
              const SizedBox(height: 12),
              AppSearchField(
                hint: 'Search products',
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
              ),
            ],
          ),
        ),
        Expanded(child: _buildList(visible)),
      ],
    );
  }

  Widget _buildList(List<Product> visible) {
    final c = context.colors;
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorState(message: _error!, onRetry: _load);
    if (visible.isEmpty) {
      return ListView(
        controller: widget.scrollController,
        children: [
          EmptyState(
            icon: Icons.sell_outlined,
            title: _products.isEmpty ? 'No products yet' : 'No matches',
            message: _products.isEmpty
                ? 'Add products under More → Products first.'
                : null,
          ),
        ],
      );
    }
    return ListView.separated(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: visible.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: c.hair),
      itemBuilder: (context, i) {
        final p = visible[i];
        final qty = _buildable[p.id] ?? 0;
        final added = widget.addedProductIds.contains(p.id);
        final available = qty > 0;
        // You can't add part of a handmade product, so its count floors.
        final shown = p.isStandalone ? qty : qty.floorToDouble();
        final stockText = !available
            ? (p.isStandalone
                ? 'Out of stock'
                : "Can't build: not enough materials")
            : (p.isStandalone
                ? 'In stock ${QuantityFormatter.withUnit(shown, p.unit)}'
                : 'Can build ${QuantityFormatter.withUnit(shown, p.unit)}');
        return Opacity(
          opacity: available ? 1 : 0.45,
          child: InkWell(
            onTap: !available
                ? null
                : () => widget.onSelected(OrderItemInput(
                      productId: p.id!,
                      productName: p.name,
                      quantity: 1,
                      unitPrice: p.sellPrice,
                      photo: p.photo,
                    )),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  ProductPhoto(bytes: p.photo, name: p.name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(p.name,
                                style: AppTextStyles.bodyLarge
                                    .copyWith(color: c.ink)),
                            if (available && isProductLow(p, qty))
                              const AppTag.low(),
                            if (added)
                              const AppTag('Added', type: AppTagType.ok),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stockText,
                          style:
                              AppTextStyles.bodySmall.copyWith(color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyFormatter.formatShort(p.sellPrice),
                    style: AppTextStyles.amount
                        .copyWith(color: c.coin, fontSize: 16),
                  ),
                  if (available) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.add_circle_outline_rounded,
                        color: c.go, size: 22),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
