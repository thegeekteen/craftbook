import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../products/domain/entities/channel.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_material.dart';
import '../bloc/order_detail_bloc.dart';
import '../bloc/order_detail_event.dart';
import '../bloc/order_detail_state.dart';
import '../widgets/pack_confirm_dialog.dart';
import 'adjust_materials_page.dart';

class OrderDetailsPage extends StatelessWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<OrderDetailBloc>()..add(LoadOrderDetail(orderId)),
      child: const _OrderDetailView(),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderDetailBloc, OrderDetailState>(
      listener: (context, state) {
        if (state is OrderDetailActionSuccess) {
          context.showSnackBar(state.message);
        }
        if (state is OrderDetailError) {
          context.showSnackBar(state.message, isError: true);
        }
        if (state is OrderDeleted) {
          context.showSnackBar('Order deleted');
          context.pop();
        }
      },
      builder: (context, state) {
        if (state is OrderDetailLoading || state is OrderDetailInitial) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OrderDetailError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order')),
            body: Center(
              child: Text(state.message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.alert)),
            ),
          );
        }

        if (state is OrderDetailLoaded) {
          return _buildLoaded(context, state);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Order')),
          body: const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildLoaded(BuildContext context, OrderDetailLoaded state) {
    final order = state.order;
    final dateFmt = DateFormat('MMM d, y');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${order.id}',
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: StatusPill(
                text: order.status.displayName,
                type: _statusPillType(order.status),
              ),
            ),
          ),
          if (order.status != OrderStatus.shipped)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: 'Delete order?',
                    message:
                        'This will permanently remove the order and reverse any stock changes.',
                    confirmText: 'Delete',
                    isDestructive: true,
                  );
                  if (confirmed && context.mounted) {
                    context
                        .read<OrderDetailBloc>()
                        .add(DeleteOrderEvent(order.id!));
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          color: AppColors.alert, size: 20),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: AppColors.alert)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status stepper
          _StatusStepper(status: order.status),
          const SizedBox(height: 24),

          // Dates
          SectionCard(
            label: 'Dates',
            child: Column(
              children: [
                _DateRow(
                    icon: Icons.calendar_today,
                    label: 'Ordered',
                    value: dateFmt.format(order.orderDate)),
                _DateRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Ship by',
                    value: dateFmt.format(order.shipByDate)),
                if (order.packedAt != null)
                  _DateRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Packed',
                      value: dateFmt.format(order.packedAt!)),
                if (order.shippedAt != null)
                  _DateRow(
                      icon: Icons.check_circle_outline,
                      label: 'Shipped',
                      value: dateFmt.format(order.shippedAt!)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Customer
          SectionCard(
            label: 'Customer',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customerName,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.ink)),
                if (order.customerAddress.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(order.customerAddress,
                            style: AppTextStyles.bodySmall),
                      ),
                    ],
                  ),
                ],
                if (order.note != null && order.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.note_outlined,
                          size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(order.note!,
                            style: AppTextStyles.bodySmall),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Channel
          if (state.channel != null) ...[
            SectionCard(
              label: 'Channel',
              child: Row(
                children: [
                  Icon(Icons.store_outlined,
                      size: 18, color: AppColors.coin),
                  const SizedBox(width: 8),
                  Text(state.channel!.name,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.ink)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Items
          SectionCard(
            label: 'Items',
            padding: EdgeInsets.zero,
            child: Column(
              children: state.items.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('No items',
                              style: AppTextStyles.bodySmall),
                        ),
                      ),
                    ]
                  : state.items.map((item) => _ItemRow(item: item)).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Materials
          SectionCard(
            label: 'Materials',
            padding: EdgeInsets.zero,
            child: Column(
              children: state.materials.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('No materials',
                              style: AppTextStyles.bodySmall),
                        ),
                      ),
                    ]
                  : state.materials
                      .map((mat) => _MaterialRow(material: mat))
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Financial summary
          SectionCard(
            label: 'Summary',
            child: Column(
              children: [
                _SummaryRow(
                    label: 'Sales',
                    amount: order.totalSales,
                    color: AppColors.success),
                _SummaryRow(
                    label: 'Materials',
                    amount: order.totalMaterialCost,
                    color: AppColors.alert),
                _SummaryRow(
                    label: 'Channel fees',
                    amount: order.channelFees,
                    color: AppColors.warning),
                _SummaryRow(
                    label: 'Shipping',
                    amount: order.shippingCost,
                    color: AppColors.muted),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: AppColors.hair, height: 1),
                ),
                _SummaryRow(
                    label: 'Profit',
                    amount: order.profit,
                    color: order.profit >= 0
                        ? AppColors.success
                        : AppColors.alert,
                    isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context, state),
    );
  }

  Widget? _buildBottomActions(
      BuildContext context, OrderDetailLoaded state) {
    final order = state.order;

    if (order.status == OrderStatus.shipped ||
        order.status == OrderStatus.cancelled) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paperHigh,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (order.status == OrderStatus.pending) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<OrderDetailBloc>(),
                          child: AdjustMaterialsPage(
                            orderId: order.id!,
                            materials: state.materials,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Adjust'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await PackConfirmDialog.show(
                      context,
                      orderMaterials: state.materials,
                      currentMaterials: [],
                    );
                    if (confirmed && context.mounted) {
                      context
                          .read<OrderDetailBloc>()
                          .add(PackOrderDetail(order.id!));
                    }
                  },
                  icon: const Icon(Icons.inventory_2, size: 18),
                  label: const Text('Pack this order'),
                ),
              ),
            ],
            if (order.status == OrderStatus.packed)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<OrderDetailBloc>()
                        .add(ShipOrderDetail(order.id!));
                  },
                  icon: const Icon(Icons.local_shipping, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coin,
                    foregroundColor: Colors.white,
                  ),
                  label: const Text('Mark shipped'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  StatusPillType _statusPillType(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return StatusPillType.warning;
      case OrderStatus.packed:
        return StatusPillType.success;
      case OrderStatus.shipped:
        return StatusPillType.coin;
      case OrderStatus.cancelled:
        return StatusPillType.neutral;
    }
  }
}

// ── Sub-widgets ──────────────────────────────────────────────

class _StatusStepper extends StatelessWidget {
  final OrderStatus status;

  const _StatusStepper({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = ['Placed', 'Packed', 'Shipped'];
    final currentIndex = status == OrderStatus.pending
        ? 0
        : status == OrderStatus.packed
            ? 1
            : status == OrderStatus.shipped
                ? 2
                : -1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.paperHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hair),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isDone = index <= currentIndex;
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.success : AppColors.hair,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  steps[index],
                  style: AppTextStyles.monoLabel.copyWith(
                    color: isDone ? AppColors.success : AppColors.muted,
                    fontWeight:
                        isDone ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DateRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Text(label,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.muted)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.ink)),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hair)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.ink)),
                const SizedBox(height: 2),
                Text('${item.quantity} × ${item.unitPrice.currency}',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          CurrencyText(
            amount: item.subtotal,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.ink, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  final OrderMaterial material;
  const _MaterialRow({required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hair)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.materialName,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(
                  'Planned: ${material.plannedQuantity} · Actual: ${material.actualQuantity}',
                  style: AppTextStyles.bodySmall,
                ),
                if (material.wasteQuantity > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Waste: ${material.wasteQuantity}${material.wasteReason != null ? ' (${material.wasteReason})' : ''}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.alert),
                    ),
                  ),
              ],
            ),
          ),
          CurrencyText(
            amount: material.totalCost,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.bodyLarge.copyWith(color: AppColors.ink)
                : AppTextStyles.bodySmall
                    .copyWith(color: AppColors.muted),
          ),
          CurrencyText(
            amount: amount,
            style: (isBold
                    ? AppTextStyles.displaySmall
                    : AppTextStyles.bodyMedium)
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
