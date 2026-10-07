import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../domain/entities/buy_list_item.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';

/// What to buy: low materials, most urgent first, with pack counts and cost.
class BuyListPage extends StatelessWidget {
  const BuyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MaterialsBloc>()..add(LoadBuyList()),
      child: const _BuyListView(),
    );
  }
}

class _BuyListView extends StatefulWidget {
  const _BuyListView();

  @override
  State<_BuyListView> createState() => _BuyListViewState();
}

class _BuyListViewState extends State<_BuyListView> {
  bool _changed = false;

  void _reload() => context.read<MaterialsBloc>().add(LoadBuyList());

  /// Urgency: blocking orders, then out of free stock, then the rest.
  static int _rank(BuyListItem i) {
    if (i.blockingOrders > 0 && i.isCritical) return 0;
    if (i.isCritical) return 1;
    return 2;
  }

  Future<void> _copy(List<BuyListItem> items) async {
    final l10n = context.l10n;
    final total = items.fold<double>(0, (s, i) => s + i.totalCost);
    final buffer = StringBuffer('${l10n.stockBuyListCopyHeader}\n\n');
    for (final i in items) {
      final pcs = i.packsToOrder * i.packSize;
      final amount = i.kind == BuyListKind.product
          ? QuantityFormatter.withUnit(pcs, i.unit)
          : '${l10n.stockPacks(i.packsToOrder)} '
              '(${QuantityFormatter.withUnit(pcs, i.unit)})';
      buffer.writeln(l10n.stockBuyListCopyLine(
          i.name, amount, CurrencyFormatter.format(i.totalCost)));
    }
    buffer.write(
        '\n${l10n.stockBuyListCopyTotal(CurrencyFormatter.format(total))}');
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) context.showSnackBar(l10n.stockBuyListCopied);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(_changed);
      },
      child: BlocBuilder<MaterialsBloc, MaterialsState>(
        builder: (context, state) {
          final items = state is BuyListLoaded
              ? ([...state.items]..sort((a, b) => _rank(a).compareTo(_rank(b))))
              : null;
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop(_changed)),
              title: Text(context.l10n.stockBuyListTitle),
            ),
            body: switch (state) {
              BuyListLoaded() when items!.isEmpty => Center(
                  child: EmptyState(
                    icon: Icons.shopping_basket_outlined,
                    title: context.l10n.stockBuyEmptyTitle,
                    message: context.l10n.stockBuyEmptyMessage,
                  ),
                ),
              BuyListLoaded() => RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    padding: AppSpacing.page.copyWith(top: 8),
                    itemCount: items!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _BuyCard(
                      item: items[i],
                      onTap: () async {
                        final item = items[i];
                        final changed = await context.push<bool>(
                            item.kind == BuyListKind.product
                                ? RouteNames.productPath(item.id)
                                : RouteNames.materialPath(item.id));
                        if (changed == true && mounted) {
                          _changed = true;
                          _reload();
                        }
                      },
                    ),
                  ),
                ),
              MaterialsError(:final message) =>
                Center(child: ErrorState(message: message, onRetry: _reload)),
              _ => const Center(child: CircularProgressIndicator()),
            },
            bottomNavigationBar: items == null || items.isEmpty
                ? null
                : BottomActionBar(children: [
                    BarTotal(
                      label: context.l10n.stockBuyItemCount(items.length),
                      value: CurrencyFormatter.format(
                          items.fold<double>(0, (s, i) => s + i.totalCost)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copy(items),
                      icon: const Icon(Icons.copy_rounded, size: 17),
                      label: Text(context.l10n.stockBuyCopyList),
                    ),
                  ]),
          );
        },
      ),
    );
  }
}

class _BuyCard extends StatelessWidget {
  final BuyListItem item;
  final VoidCallback onTap;

  const _BuyCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final holdingUp =
        item.blockedProducts.where((p) => p.openOrderCount > 0).toList();
    final blockedOrders = item.blockingOrders;
    final isProduct = item.kind == BuyListKind.product;
    final pcs = item.packsToOrder * item.packSize;

    return AppCard(
      onTap: onTap,
      borderColor: item.isCritical ? c.alert.withValues(alpha: 0.55) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.name,
                    style: AppTextStyles.bodyLarge.copyWith(color: c.ink)),
              ),
              const SizedBox(width: 8),
              if (isProduct) ...[
                AppTag(l10n.stockBuyTagResell),
                const SizedBox(width: 6),
              ],
              if (item.isCritical && blockedOrders > 0)
                AppTag(l10n.stockBuyTagBlocking(blockedOrders),
                    type: AppTagType.low)
              else if (item.isCritical)
                AppTag(l10n.stockBuyTagOutOfFree, type: AppTagType.low)
              else
                AppTag(l10n.stockBuyTagBelowReorder, type: AppTagType.warn),
            ],
          ),
          const SizedBox(height: 10),
          PipStrip(
            total: item.quantityOnHand,
            free: item.quantityFree,
            promised: item.quantityPromised,
            alertLevel: item.alertLevel,
            unit: item.unit,
            isLow: true,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '${l10n.stockBuyVerb} '),
                    TextSpan(
                      text: isProduct
                          ? QuantityFormatter.withUnit(pcs, item.unit)
                          : l10n.stockPacks(item.packsToOrder),
                      style:
                          TextStyle(color: c.ink, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                        text:
                            '${isProduct ? '' : ' · ${QuantityFormatter.withUnit(pcs, item.unit)}'}'
                            ' · ${l10n.stockBuyFreeNow(QuantityFormatter.withUnit(item.quantityFree < 0 ? 0 : item.quantityFree, item.unit))}'),
                  ]),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: c.muted, fontSize: 13),
                ),
              ),
              Text(
                CurrencyFormatter.format(item.totalCost),
                style:
                    AppTextStyles.amount.copyWith(color: c.coin, fontSize: 16),
              ),
            ],
          ),
          if (holdingUp.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              l10n.stockBuyHoldsUp(holdingUp
                  .map((p) => '${p.productName} (${p.openOrderCount})')
                  .join(', ')),
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ],
        ],
      ),
    );
  }
}
