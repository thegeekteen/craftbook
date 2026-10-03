import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../../../core/widgets/section_label.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_detail_bloc.dart';
import '../bloc/order_detail_event.dart';
import '../bloc/order_detail_state.dart';
import '../widgets/order_status_ui.dart';
import '../widgets/pack_confirm_sheet.dart';
import 'adjust_materials_page.dart';

/// One order: progress, customer, items, and where the money went.
class OrderDetailsPage extends StatelessWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderDetailBloc>()..add(LoadOrderDetail(orderId)),
      child: _OrderDetailView(orderId: orderId),
    );
  }
}

class _OrderDetailView extends StatefulWidget {
  final int orderId;

  const _OrderDetailView({required this.orderId});

  @override
  State<_OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<_OrderDetailView> {
  /// Tells the previous screen to reload when we go back.
  bool _changed = false;
  bool _showMaterials = false;

  OrderDetailBloc get _bloc => context.read<OrderDetailBloc>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(_changed);
      },
      child: BlocConsumer<OrderDetailBloc, OrderDetailState>(
        listener: (context, state) {
          if (state is OrderDetailMessage) {
            if (!state.isError) _changed = true;
            context.showSnackBar(state.message, isError: state.isError);
          }
          if (state is OrderDeleted) {
            context.showSnackBar('Order deleted');
            context.pop(true);
          }
        },
        buildWhen: (_, s) => s is! OrderDetailMessage && s is! OrderDeleted,
        builder: (context, state) {
          return switch (state) {
            OrderDetailLoaded() => _buildLoaded(state),
            OrderDetailError(:final message) => Scaffold(
                appBar: AppBar(leading: BackButton(onPressed: () => context.pop(_changed))),
                body: Center(
                  child: ErrorState(
                    message: message,
                    onRetry: () => _bloc.add(LoadOrderDetail(widget.orderId)),
                  ),
                ),
              ),
            _ => Scaffold(
                appBar: AppBar(),
                body: const Center(child: CircularProgressIndicator()),
              ),
          };
        },
      ),
    );
  }

  Widget _buildLoaded(OrderDetailLoaded state) {
    final c = context.colors;
    final order = state.order;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop(_changed)),
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ORDER #${order.id}',
              style: AppTextStyles.monoLabel.copyWith(color: c.muted),
            ),
            Text(order.customerName, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          if (order.status != OrderStatus.shipped)
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'delete') _confirmDelete(order);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 20, color: c.alert),
                      const SizedBox(width: 10),
                      Text('Delete order', style: TextStyle(color: c.alert)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: AppSpacing.page.copyWith(top: 8),
            children: [
              _StatusTrack(order: order),
              const SizedBox(height: 12),
              _CustomerCard(order: order, channelName: state.channel?.name),
              const SizedBox(height: 12),
              if (state.items.isNotEmpty) ...[
                AppCard.flush(
                  child: CardList(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        child: Text(
                          'ITEMS',
                          style: AppTextStyles.monoLabel.copyWith(color: c.muted),
                        ),
                      ),
                      for (final item in state.items)
                        CardRow(
                          title: Text(item.productName),
                          subtitle: Text(
                            '${item.quantity} × ${CurrencyFormatter.formatShort(item.unitPrice)}',
                          ),
                          trailing: Text(
                            CurrencyFormatter.format(item.subtotal),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: c.ink,
                              fontWeight: FontWeight.w600,
                              fontFeatures: AppTextStyles.tabular.fontFeatures,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _buildProfitCard(state),
            ],
          ),
          if (state.isBusy)
            const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator()),
        ],
      ),
      bottomNavigationBar: _buildActions(state),
    );
  }

  Widget _buildProfitCard(OrderDetailLoaded state) {
    final c = context.colors;
    final order = state.order;
    final parts = MoneyParts(
      sales: order.totalSales,
      materials: order.totalMaterialCost,
      fees: order.channelFees,
      shipping: order.shippingCost,
    );
    final lineCount = state.materials.length + state.products.length;
    final hasWaste = state.materials.any((m) => m.wasteQuantity > 0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text('PROFIT', style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
              ),
              Text(
                CurrencyFormatter.format(parts.profit),
                style: AppTextStyles.displayMedium.copyWith(
                  fontSize: 26,
                  color: parts.profit >= 0 ? c.go : c.alert,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MoneyBreakdown(
            parts: parts,
            materialsLabel: lineCount == 0
                ? 'Materials'
                : 'Materials · $lineCount ${lineCount == 1 ? 'line' : 'lines'}'
                    '${hasWaste ? ' · waste' : ''}',
            feesLabel: state.channel == null ? 'Channel fees' : '${state.channel!.name} fees',
            onMaterialsTap: lineCount == 0
                ? null
                : () => setState(() => _showMaterials = !_showMaterials),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !_showMaterials
                ? const SizedBox(width: double.infinity)
                : Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.paper,
                      borderRadius: AppRadii.controlAll,
                    ),
                    child: Column(
                      children: [
                        for (final m in state.materials)
                          _LineDetail(
                            name: m.materialName,
                            detail: m.actualQuantity == m.plannedQuantity
                                ? '${m.actualQuantity} × ${CurrencyFormatter.format(m.unitCost)}'
                                : 'Planned ${m.plannedQuantity} · used ${m.actualQuantity}',
                            waste: m.wasteQuantity > 0
                                ? '+${m.wasteQuantity} waste'
                                    '${m.wasteReason != null ? ' (${m.wasteReason!.toLowerCase()})' : ''}'
                                : null,
                            amount: m.totalCost,
                          ),
                        for (final p in state.products)
                          _LineDetail(
                            name: p.productName,
                            detail: '${p.quantity} × ${CurrencyFormatter.format(p.unitCost)} · from stock',
                            amount: p.totalCost,
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget? _buildActions(OrderDetailLoaded state) {
    final c = context.colors;
    final order = state.order;
    final busy = state.isBusy;
    switch (order.status) {
      case OrderStatus.pending:
        return BottomActionBar(children: [
          if (state.materials.isNotEmpty)
            OutlinedButton(
              onPressed: busy ? null : () => _openAdjust(state),
              child: const Text('Adjust'),
            ),
          Expanded(
            child: FilledButton.icon(
              onPressed: busy ? null : () => _pack(state),
              icon: const Icon(Icons.inventory_2_rounded, size: 18),
              label: const Text('Pack order'),
            ),
          ),
        ]);
      case OrderStatus.packed:
        return BottomActionBar(children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: busy ? null : () => _bloc.add(ShipOrderDetail(order.id!)),
              style: FilledButton.styleFrom(backgroundColor: c.coin),
              icon: const Icon(Icons.local_shipping_rounded, size: 18),
              label: const Text('Mark shipped'),
            ),
          ),
        ]);
      case OrderStatus.shipped:
      case OrderStatus.cancelled:
        return null;
    }
  }

  Future<void> _pack(OrderDetailLoaded state) async {
    final confirmed = await PackConfirmSheet.show(
      context,
      materials: state.materials,
      products: state.products,
      materialStock: state.materialStock,
      productStock: state.productStock,
    );
    if (confirmed && mounted) _bloc.add(PackOrderDetail(state.order.id!));
  }

  Future<void> _openAdjust(OrderDetailLoaded state) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _bloc,
          child: AdjustMaterialsPage(orderId: state.order.id!, materials: state.materials),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Order order) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete order #${order.id}?',
      message: order.status == OrderStatus.packed
          ? 'The order is removed and its materials go back on the shelf.'
          : 'The order is removed and its reserved stock is released.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) _bloc.add(DeleteOrderEvent(order.id!));
  }
}

/// Placed → Packed → Shipped with the date under each step.
class _StatusTrack extends StatelessWidget {
  final Order order;

  const _StatusTrack({required this.order});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fmt = DateFormat('MMM d');
    if (order.status == OrderStatus.cancelled) {
      return AppCard(
        child: Row(
          children: [
            const OrderStatusPill(status: OrderStatus.cancelled),
            const SizedBox(width: 10),
            Text(
              'Placed ${fmt.format(order.orderDate)}',
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ],
        ),
      );
    }

    final reached = switch (order.status) {
      OrderStatus.pending => 0,
      OrderStatus.packed => 1,
      _ => 2,
    };
    final overdue = order.isOverdue;
    final steps = [
      ('Placed', fmt.format(order.orderDate), false),
      (
        'Packed',
        order.packedAt != null
            ? fmt.format(order.packedAt!)
            : 'due ${fmt.format(order.shipByDate)}',
        overdue,
      ),
      (
        'Shipped',
        order.shippedAt != null ? fmt.format(order.shippedAt!) : '',
        false,
      ),
    ];

    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++)
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 28,
                    child: Row(
                      children: [
                        Expanded(
                          child: i == 0
                              ? const SizedBox()
                              : Container(height: 2, color: i <= reached ? c.go : c.hair),
                        ),
                        _TrackDot(index: i, reached: reached, alert: steps[i].$3),
                        Expanded(
                          child: i == steps.length - 1
                              ? const SizedBox()
                              : Container(height: 2, color: i < reached ? c.go : c.hair),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[i].$1,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: i <= reached + 1 ? c.ink : c.muted,
                      fontWeight: i <= reached + 1 ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (steps[i].$2.isNotEmpty)
                    Text(
                      steps[i].$2,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: steps[i].$3 ? c.alert : c.muted,
                        fontWeight: steps[i].$3 ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TrackDot extends StatelessWidget {
  final int index;
  final int reached;
  final bool alert;

  const _TrackDot({required this.index, required this.reached, required this.alert});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = index <= reached;
    final current = index == reached + 1;
    final ring = alert ? c.alert : c.go;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? c.go : c.surface,
        border: Border.all(color: done || current ? ring : c.hair, width: 2),
      ),
      child: Center(
        child: done
            ? Icon(Icons.check_rounded, size: 16, color: c.onAccent)
            : Text(
                '${index + 1}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: current ? ring : c.muted,
                ),
              ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Order order;
  final String? channelName;

  const _CustomerCard({required this.order, this.channelName});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final muted = AppTextStyles.bodySmall.copyWith(color: c.muted, fontSize: 13);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SectionLabel('Customer', padding: EdgeInsets.zero)),
              if (channelName != null) AppTag(channelName!, type: AppTagType.outline),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.customerName, style: AppTextStyles.bodyLarge.copyWith(color: c.ink)),
          if (order.customerAddress.isNotEmpty) ...[
            const SizedBox(height: 2),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                Clipboard.setData(ClipboardData(text: order.customerAddress));
                context.showSnackBar('Address copied');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(order.customerAddress, style: muted)),
                    const SizedBox(width: 8),
                    Icon(Icons.copy_rounded, size: 15, color: c.muted),
                  ],
                ),
              ),
            ),
          ],
          if (order.note != null && order.note!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: c.warnSoft,
                borderRadius: AppRadii.controlAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined, size: 16, color: c.warn),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.note!,
                      style: AppTextStyles.bodySmall.copyWith(color: c.ink, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LineDetail extends StatelessWidget {
  final String name;
  final String detail;
  final String? waste;
  final double amount;

  const _LineDetail({
    required this.name,
    required this.detail,
    this.waste,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: c.ink, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(detail, style: AppTextStyles.bodySmall.copyWith(color: c.muted, fontSize: 12)),
                if (waste != null)
                  Text(
                    waste!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: c.alert, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTextStyles.bodySmall.copyWith(
              color: c.ink,
              fontSize: 13,
              fontFeatures: AppTextStyles.tabular.fontFeatures,
            ),
          ),
        ],
      ),
    );
  }
}
