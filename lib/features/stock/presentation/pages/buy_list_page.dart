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
    final total = items.fold<double>(0, (s, i) => s + i.totalCost);
    final buffer = StringBuffer('CraftBook buy list\n\n');
    for (final i in items) {
      final pcs = i.packsToOrder * i.packSize;
      final amount = i.kind == BuyListKind.product
          ? '$pcs pcs'
          : '${i.packsToOrder} ${i.packsToOrder == 1 ? 'pack' : 'packs'} '
              '($pcs pcs)';
      buffer.writeln(
          '- ${i.name}: $amount, ${CurrencyFormatter.format(i.totalCost)}');
    }
    buffer.write('\nTotal: ${CurrencyFormatter.format(total)}');
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) context.showSnackBar('Buy list copied');
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
              title: const Text('Buy list'),
            ),
            body: switch (state) {
              BuyListLoaded() when items!.isEmpty => const Center(
                  child: EmptyState(
                    icon: Icons.shopping_basket_outlined,
                    title: 'Nothing to buy',
                    message: 'Everything is above its reorder level.',
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
                      label:
                          '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                      value: CurrencyFormatter.format(
                          items.fold<double>(0, (s, i) => s + i.totalCost)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copy(items),
                      icon: const Icon(Icons.copy_rounded, size: 17),
                      label: const Text('Copy list'),
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
                const AppTag('Resell'),
                const SizedBox(width: 6),
              ],
              if (item.isCritical && blockedOrders > 0)
                AppTag(
                    'Blocking $blockedOrders ${blockedOrders == 1 ? 'order' : 'orders'}',
                    type: AppTagType.low)
              else if (item.isCritical)
                const AppTag('Out of free stock', type: AppTagType.low)
              else
                const AppTag('Below reorder', type: AppTagType.warn),
            ],
          ),
          const SizedBox(height: 10),
          PipStrip(
            total: item.quantityOnHand,
            free: item.quantityFree,
            promised: item.quantityPromised,
            alertLevel: item.alertLevel,
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
                    const TextSpan(text: 'Buy '),
                    TextSpan(
                      text: isProduct
                          ? '$pcs pcs'
                          : '${item.packsToOrder} ${item.packsToOrder == 1 ? 'pack' : 'packs'}',
                      style:
                          TextStyle(color: c.ink, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                        text: '${isProduct ? '' : ' · $pcs pcs'}'
                            ' · ${item.quantityFree < 0 ? 0 : item.quantityFree} free now'),
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
              'Holds up: ${holdingUp.map((p) => '${p.productName} (${p.openOrderCount})').join(', ')}',
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ],
        ],
      ),
    );
  }
}
