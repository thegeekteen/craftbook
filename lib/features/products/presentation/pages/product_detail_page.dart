import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_history_entry.dart';
import '../../domain/product_stock_status.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/adjust_product_stock.dart';
import '../../domain/usecases/get_pending_order_counts.dart';
import '../../domain/usecases/get_product_history.dart';
import '../widgets/product_actions.dart';
import '../widgets/product_history_row.dart';
import '../widgets/product_profit_card.dart';
import '../widgets/product_summary_card.dart';

/// One product: what's available, its materials, profit and history.
/// Editing lives behind the menu so looking never risks a stray save.
class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? _product;
  List<BomItem> _bom = [];

  /// Unclamped: negative when reservations exceed what's on hand.
  int _buildable = 0;
  int _pendingOrders = 0;
  List<ProductHistoryEntry> _history = [];
  String? _historyError;
  bool _loading = true;
  String? _error;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = getIt<ProductRepository>();
    final productResult = await repo.getProductById(widget.productId);
    final bomResult = await repo.getBomItems(widget.productId);
    final buildableResult =
        await repo.calculateBuildableQuantity(widget.productId);
    final historyResult = await getIt<GetProductHistory>()(widget.productId);
    final pendingResult = await getIt<GetPendingOrderCounts>()();
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (productResult) {
        case Error(:final failure):
          _error = failure.message;
        case Success(:final value) when value == null:
          _error = 'Product not found';
        case Success(:final value):
          _product = value;
          _error = null;
      }
      _bom = switch (bomResult) {
        Success(:final value) => value,
        Error() => [],
      };
      _buildable = switch (buildableResult) {
        Success(:final value) => value,
        Error() => 0,
      };
      _pendingOrders = switch (pendingResult) {
        Success(:final value) => value[widget.productId] ?? 0,
        Error() => 0,
      };
      switch (historyResult) {
        case Success(:final value):
          _history = value;
          _historyError = null;
        case Error(:final failure):
          _historyError = failure.message;
      }
    });
  }

  double get _cost {
    final p = _product!;
    return p.isStandalone
        ? p.unitCost
        : _bom.fold(0.0, (s, b) => s + b.quantityRequired * b.materialUnitCost);
  }

  /// Pushes [location] and reloads if the child page changed something.
  Future<void> _open(String location) async {
    final changed = await context.push<bool>(location);
    if (changed == true && mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _count(Product p) async {
    var counted = p.quantityOnHand;
    final save = await showAppSheet<bool>(
      context: context,
      title: 'Count stock',
      subtitle: 'Set how many are actually on the shelf.',
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: StepperInput(
                value: counted,
                min: 0,
                max: 99999,
                onChanged: (v) => setSheet(() => counted = v.toInt()),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: counted == p.quantityOnHand
                  ? null
                  : () => Navigator.pop(sheetContext, true),
              child: const Text('Save count'),
            ),
          ],
        ),
      ),
    );
    if (save != true || !mounted) return;
    final result = await getIt<AdjustProductStock>()(
        productId: p.id!, newQuantityOnHand: counted);
    if (!mounted) return;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
      case Success():
        context.showSnackBar('Stock set to $counted');
        _changed = true;
        _load();
    }
  }

  Future<void> _toggleArchived(Product p) async {
    if (await ProductActions.setArchived(context, p, !p.isArchived) &&
        mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _delete(Product p) async {
    if (await ProductActions.delete(context, p) && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(_changed);
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    final back = BackButton(onPressed: () => context.pop(_changed));
    if (_loading) {
      return Scaffold(
          appBar: AppBar(leading: back),
          body: const Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(leading: back),
        body: Center(
            child: ErrorState(
                message: _error ?? 'Product not found', onRetry: _load)),
      );
    }
    final c = context.colors;
    final p = _product!;
    final cost = _cost;

    return Scaffold(
      appBar: AppBar(
        leading: back,
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) {
              if (v == 'edit') {
                _open(RouteNames.productEditorPath(widget.productId));
              }
              if (v == 'archive') _toggleArchived(p);
              if (v == 'delete') _delete(p);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 10),
                  Text('Edit product'),
                ]),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Row(children: [
                  Icon(
                      p.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      size: 20),
                  const SizedBox(width: 10),
                  Text(p.isArchived ? 'Unarchive' : 'Archive'),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded, size: 20, color: c.alert),
                  const SizedBox(width: 10),
                  Text('Delete product', style: TextStyle(color: c.alert)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: AppSpacing.page.copyWith(top: 8),
          children: [
            ProductSummaryCard(
              product: p,
              cost: cost,
              buildable: _buildable < 0 ? 0 : _buildable,
              isShort: isProductShort(p,
                  rawBuildable: _buildable, pendingOrders: _pendingOrders),
            ),
            if (p.isStandalone) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _open(
                        RouteNames.receiveProductStockPath(widget.productId)),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Receive'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _count(p),
                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                    label: const Text('Count'),
                  ),
                ),
              ]),
            ] else ...[
              const SizedBox(height: 8),
              SectionLabel('Materials per piece · ${_bom.length}'),
              const SizedBox(height: 8),
              if (_bom.isEmpty)
                _quiet('No materials yet. Edit the product to add them.')
              else
                AppCard.flush(
                  child: CardList(children: [
                    for (final b in _bom)
                      CardRow(
                        title: Text(b.materialName),
                        subtitle: Text(
                            '${b.quantityRequired} × ${CurrencyFormatter.format(b.materialUnitCost)}'),
                        trailing: Text(
                          CurrencyFormatter.format(
                              b.quantityRequired * b.materialUnitCost),
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: c.coin, fontWeight: FontWeight.w600),
                        ),
                        onTap: () =>
                            _open(RouteNames.materialPath(b.materialId)),
                      ),
                  ]),
                ),
            ],
            const SizedBox(height: 12),
            ProductProfitCard(
                sellPrice: p.sellPrice,
                cost: cost,
                isStandalone: p.isStandalone),
            const SectionLabel('History',
                padding: EdgeInsets.fromLTRB(2, 16, 2, 0)),
            const SizedBox(height: 8),
            if (_historyError != null)
              _quiet("Couldn't load history: $_historyError")
            else if (_history.isEmpty)
              _quiet('No sales or stock changes yet.')
            else
              AppCard.flush(
                child: CardList(children: [
                  for (final e in _history.take(30))
                    ProductHistoryRow(
                        entry: e,
                        onOrderTap: (id) => _open(RouteNames.orderPath(id))),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quiet(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
        child: Text(text,
            style:
                AppTextStyles.bodySmall.copyWith(color: context.colors.muted)),
      );
}
