import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/buy_list_item.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';

/// Buy list page — what materials to buy
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

class _BuyListView extends StatelessWidget {
  const _BuyListView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MaterialsBloc, MaterialsState>(
      listener: (context, state) {
        if (state is MaterialsError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'What to buy',
              style:
                  AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MaterialsState state) {
    if (state is MaterialsLoading || state is MaterialsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BuyListLoaded) {
      if (state.items.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_basket_outlined,
                  color: AppColors.muted, size: 48),
              const SizedBox(height: 12),
              Text(
                'Nothing to buy!',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                'All materials are well stocked',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        );
      }

      // Sort by severity: critical first, then by free qty ascending
      final sorted = List<BuyListItem>.from(state.items)
        ..sort((a, b) {
          if (a.isCritical != b.isCritical) {
            return a.isCritical ? -1 : 1;
          }
          return a.quantityFree.compareTo(b.quantityFree);
        });

      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<MaterialsBloc>().add(LoadBuyList());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  return _BuyListItemCard(item: sorted[index]);
                },
              ),
            ),
          ),

          // Summary bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.paperHigh,
              border: Border(top: BorderSide(color: AppColors.hair)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${sorted.length} items · Total',
                          style: AppTextStyles.monoSection,
                        ),
                        const SizedBox(height: 2),
                        CurrencyText(
                          amount: state.items.fold(0.0, (sum, i) => sum + i.totalCost),
                          style: AppTextStyles.displaySmall
                              .copyWith(color: AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      final totalCost = state.items.fold(0.0, (sum, i) => sum + i.totalCost);
                      final text = _buildShareText(sorted, totalCost);
                      Clipboard.setData(ClipboardData(text: text));
                      context.showSnackBar('List copied to clipboard');
                    },
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (state is MaterialsError) {
      return Center(
        child: Text(state.message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.alert)),
      );
    }

    return const SizedBox.shrink();
  }

  String _buildShareText(List<BuyListItem> items, double totalCost) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 Craftbook — Buy List');
    buffer.writeln('');
    for (final item in items) {
      buffer.writeln(
          '• ${item.materialName}: ${item.packsToOrder} packs (${item.packsToOrder * item.packSize} pcs) — ${item.packPrice.currency}');
    }
    buffer.writeln('');
    buffer.writeln('Total: ${totalCost.currency}');
    return buffer.toString();
  }
}

class _BuyListItemCard extends StatelessWidget {
  final BuyListItem item;

  const _BuyListItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: BorderSide(
          color: item.isCritical
              ? AppColors.alert.withOpacity(0.4)
              : AppColors.hair,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: name + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.materialName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: item.isCritical
                          ? AppColors.alert
                          : AppColors.ink,
                    ),
                  ),
                ),
                if (item.isCritical)
                  const StatusPill(
                    text: 'CRITICAL',
                    type: StatusPillType.alert,
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Stock info
            Row(
              children: [
                Text(
                  'On hand: ${item.quantityOnHand}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 8),
                Text(
                  'Promised: ${item.quantityPromised}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.alert),
                ),
                const Spacer(),
                Text(
                  'Free: ${item.quantityFree}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: item.quantityFree <= 0
                        ? AppColors.alert
                        : AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Order info
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order',
                          style: AppTextStyles.monoLabel
                              .copyWith(color: AppColors.muted, fontSize: 8)),
                      const SizedBox(height: 1),
                      Text(
                        '${item.packsToOrder} packs',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.ink),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cost',
                          style: AppTextStyles.monoLabel
                              .copyWith(color: AppColors.muted, fontSize: 8)),
                      const SizedBox(height: 1),
                      CurrencyText(
                        amount: item.totalCost,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.coin),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Blocked products
            if (item.blockedProducts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('BLOCKED PRODUCTS',
                  style: AppTextStyles.monoLabel
                      .copyWith(color: AppColors.warning, fontSize: 8)),
              const SizedBox(height: 4),
              ...item.blockedProducts.map((bp) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• ${bp.productName} (${bp.openOrderCount} orders)',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.warning),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
