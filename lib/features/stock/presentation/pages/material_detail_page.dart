import 'package:flutter/material.dart' hide Material;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/adjust_stock.dart';
import '../../domain/usecases/get_material_detail.dart';
import '../widgets/material_actions.dart';

/// One material: stock with pips, cost facts, where it's used, history.
class MaterialDetailPage extends StatefulWidget {
  final int materialId;

  const MaterialDetailPage({super.key, required this.materialId});

  @override
  State<MaterialDetailPage> createState() => _MaterialDetailPageState();
}

class _MaterialDetailPageState extends State<MaterialDetailPage> {
  Material? _material;
  List<StockMovement> _movements = [];

  /// Products using this material and how many pieces each needs.
  List<(Product, String)> _usedIn = [];
  bool _loading = true;
  String? _error;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<GetMaterialDetail>()(widget.materialId);
    if (!mounted) return;
    final l10n = context.l10n;
    switch (result) {
      case Error(:final failure):
        setState(() {
          _error = failure.message;
          _loading = false;
        });
      case Success(:final value):
        final repo = getIt<ProductRepository>();
        final usedIn = <(Product, String)>[];
        final productsResult =
            await repo.getProductsUsingMaterial(widget.materialId);
        if (productsResult case Success(value: final products)) {
          for (final p in products) {
            final bom = await repo.getBomItems(p.id!);
            final usage = switch (bom) {
              Success(:final value) => value
                  .where((b) => b.materialId == widget.materialId)
                  .map((b) => b.makes > 1
                      ? l10n.stockUsagePer(
                          QuantityFormatter.withUnit(
                              b.quantityRequired, b.materialUnit),
                          QuantityFormatter.format(b.makes))
                      : l10n.stockUsageEach(QuantityFormatter.withUnit(
                          b.quantityRequired, b.materialUnit)))
                  .join(' + '),
              Error() => '',
            };
            usedIn.add((p, usage));
          }
        }
        if (!mounted) return;
        setState(() {
          _material = value.material;
          _movements = value.movements
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _usedIn = usedIn;
          _loading = false;
          _error = null;
        });
    }
  }

  Future<void> _receive() async {
    final changed = await context
        .push<bool>(RouteNames.receiveStockPath(widget.materialId));
    if (changed == true && mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _edit() async {
    final changed = await context
        .push<bool>(RouteNames.editMaterialPath(widget.materialId));
    if (changed == true && mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _openProduct(int productId) async {
    final changed = await context.push<bool>(RouteNames.productPath(productId));
    if (changed == true && mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _count(Material m) async {
    var counted = m.quantityOnHand;
    final l10n = context.l10n;
    final save = await showAppSheet<bool>(
      context: context,
      title: l10n.stockCountTitle,
      subtitle: l10n.stockCountSubtitle,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          final c = sheetContext.colors;
          final diff = qty(counted - m.quantityOnHand);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: StepperInput(
                  value: counted,
                  min: 0,
                  max: 99999,
                  decimals: quantityDecimals,
                  onChanged: (v) => setSheet(() => counted = qty(v.toDouble())),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                sameQty(diff, 0)
                    ? l10n.stockCountMatches(
                        QuantityFormatter.format(m.quantityOnHand))
                    : l10n.stockCountDiff(
                        '${diff > 0 ? '+' : '−'}${QuantityFormatter.format(diff.abs())}',
                        QuantityFormatter.format(m.quantityOnHand)),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      sameQty(diff, 0) ? c.muted : (diff > 0 ? c.go : c.alert),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: sameQty(diff, 0)
                    ? null
                    : () => Navigator.pop(sheetContext, true),
                child: Text(l10n.stockCountSave),
              ),
            ],
          );
        },
      ),
    );
    if (save != true || !mounted) return;
    final result = await getIt<AdjustStock>()(widget.materialId, counted);
    if (!mounted) return;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
      case Success():
        context.showSnackBar(
            l10n.stockCountSet(QuantityFormatter.withUnit(counted, m.unit)));
        _changed = true;
        _load();
    }
  }

  Future<void> _toggleArchived(Material m) async {
    if (await MaterialActions.setArchived(context, m, !m.isArchived) &&
        mounted) {
      _changed = true;
      _load();
    }
  }

  Future<void> _delete(Material m) async {
    if (await MaterialActions.delete(context, m) && mounted) context.pop(true);
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
    if (_error != null || _material == null) {
      return Scaffold(
        appBar: AppBar(leading: back),
        body: Center(
            child: ErrorState(
                message: _error ?? context.l10n.stockMaterialNotFound,
                onRetry: _load)),
      );
    }
    final c = context.colors;
    final l10n = context.l10n;
    final m = _material!;
    final low = m.isLowStock && !m.isArchived;

    return Scaffold(
      appBar: AppBar(
        leading: back,
        title: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) {
              if (v == 'edit') _edit();
              if (v == 'archive') _toggleArchived(m);
              if (v == 'delete') _delete(m);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  const Icon(Icons.edit_outlined, size: 20),
                  const SizedBox(width: 10),
                  Text(l10n.stockActionEdit),
                ]),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Row(children: [
                  Icon(
                      m.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      size: 20),
                  const SizedBox(width: 10),
                  Text(
                      m.isArchived ? l10n.commonUnarchive : l10n.commonArchive),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded, size: 20, color: c.alert),
                  const SizedBox(width: 10),
                  Text(l10n.stockActionDelete,
                      style: TextStyle(color: c.alert)),
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
            AppCard(
              borderColor: low ? c.alert.withValues(alpha: 0.55) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        QuantityFormatter.format(m.quantityOnHand),
                        style: AppTextStyles.displayLarge.copyWith(
                            color: low ? c.alert : c.ink, fontSize: 44),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          m.unit.isEmpty
                              ? l10n.stockOnHandCaption
                              : l10n
                                  .stockUnitOnHandCaption(m.unit.toUpperCase()),
                          style:
                              AppTextStyles.monoLabel.copyWith(color: c.muted)),
                      const Spacer(),
                      if (m.isArchived) AppTag(l10n.stockArchivedTag),
                      if (low) const AppTag.low(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PipStrip(
                    total: m.quantityOnHand,
                    free: m.quantityFree,
                    promised: m.quantityPromised,
                    alertLevel: m.alertLevel,
                    unit: m.unit,
                    isLow: low,
                    size: PipSize.large,
                  ),
                  const SizedBox(height: 8),
                  const PipLegend(),
                  const SizedBox(height: 14),
                  StatRow(children: [
                    m.quantityFree < 0
                        ? StatTile(
                            label: l10n.stockStatShort,
                            value: QuantityFormatter.format(-m.quantityFree),
                            valueColor: c.alert)
                        : StatTile(
                            label: l10n.stockStatFree,
                            value: QuantityFormatter.format(m.quantityFree),
                            valueColor: c.go),
                    StatTile(
                        label: l10n.stockStatPromised,
                        value: QuantityFormatter.format(m.quantityPromised),
                        valueColor: m.quantityPromised > 0 ? c.alert : null),
                    StatTile(
                        label: l10n.stockStatReorderAt,
                        value: QuantityFormatter.format(m.alertLevel)),
                  ]),
                  const SizedBox(height: 12),
                  Divider(color: c.hair),
                  const SizedBox(height: 12),
                  StatRow(children: [
                    StatTile(
                        label: l10n.stockStatUnitCost,
                        value: CurrencyFormatter.format(m.unitCost),
                        compact: true),
                    StatTile(
                        label: l10n.stockStatPack,
                        value: QuantityFormatter.withUnit(m.packSize, m.unit),
                        compact: true),
                    StatTile(
                        label: l10n.stockStatSupplier,
                        value:
                            m.supplier?.isNotEmpty == true ? m.supplier! : '—',
                        compact: true),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _receive,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(l10n.stockReceive),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _count(m),
                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                    label: Text(l10n.stockCount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SectionLabel(l10n.stockUsedIn(_usedIn.length)),
            const SizedBox(height: 8),
            if (_usedIn.isEmpty)
              _quiet(l10n.stockUsedInEmpty)
            else
              AppCard.flush(
                child: CardList(children: [
                  for (final (p, usage) in _usedIn)
                    CardRow(
                      title: Text(p.name),
                      trailing: Text(
                        usage,
                        style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                      ),
                      onTap: () => _openProduct(p.id!),
                    ),
                ]),
              ),
            const SizedBox(height: 8),
            SectionLabel(l10n.stockHistory),
            const SizedBox(height: 8),
            if (_movements.isEmpty)
              _quiet(l10n.stockHistoryEmpty)
            else
              AppCard.flush(
                child: CardList(children: [
                  for (final mv in _movements.take(30))
                    _MovementRow(movement: mv, unit: m.unit),
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

class _MovementRow extends StatelessWidget {
  final StockMovement movement;

  /// The material's unit, for the per-unit cost on a receive row.
  final String unit;

  const _MovementRow({required this.movement, this.unit = ''});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final mv = movement;
    final adds = mv.type == StockMovementType.received ||
        (mv.type == StockMovementType.adjusted && mv.quantity > 0);
    final color = adds ? c.go : c.alert;
    final qty = mv.quantity.abs();
    final title = switch (mv.type) {
      StockMovementType.received => mv.reference?.contains('Restored') == true
          ? l10n.stockMoveReturned
          : l10n.stockMoveReceived,
      StockMovementType.deducted => l10n.stockMoveUsed,
      StockMovementType.adjusted => l10n.stockMoveCounted,
      StockMovementType.waste => l10n.stockMoveWaste,
    };
    final when = DateFormat('MMM d, y').format(mv.createdAt);
    return CardRow(
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: adds ? c.goSoft : c.alertSoft,
          shape: BoxShape.circle,
        ),
        child: Icon(adds ? Icons.south_west_rounded : Icons.north_east_rounded,
            size: 16, color: color),
      ),
      title: Text(title),
      subtitle: Text(
        mv.type == StockMovementType.received && mv.unitCost > 0
            ? '$when · ${CurrencyFormatter.format(mv.unitCost)}'
                '${unit.isEmpty ? '' : '/$unit'}'
            : when,
      ),
      trailing: Text(
        '${adds ? '+' : '−'}${QuantityFormatter.format(qty)}',
        style: AppTextStyles.amount.copyWith(color: color, fontSize: 15),
      ),
    );
  }
}
