import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_material.dart';
import '../bloc/order_detail_bloc.dart';
import '../bloc/order_detail_event.dart';
import '../bloc/order_detail_state.dart';
import '../widgets/pack_confirm_dialog.dart';
import 'adjust_materials_page.dart';

/// Order detail view — Flow 3
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
                        'This will permanently remove the order and reverse any stock changes. This cannot be undone.',
                    confirmText: 'Delete',
                    isDestructive: true,
                  );
                  if (confirmed && context.mounted) {
                    context.read<OrderDetailBloc>().add(
                          DeleteOrderEvent(order.id!),
                        );
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
          const SizedBox(height: 20),

          // Customer info
          _SectionLabel('CUSTOMER'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.paperHigh,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.hair),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customerName,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.ink)),
                if (order.customerAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(order.customerAddress,
                      style: AppTextStyles.bodySmall),
                ],
                if (order.note != null && order.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Note: ${order.note}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.muted)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Items
          _SectionLabel('ITEMS'),
          const SizedBox(height: 8),
          ...state.items.map((item) => _ItemRow(item: item)),
          const SizedBox(height: 20),

          // Materials
          _SectionLabel('MATERIALS'),
          const SizedBox(height: 8),
          ...state.materials.map((mat) => _MaterialRow(material: mat)),
          const SizedBox(height: 20),

          // Financial summary
          _SectionLabel('SUMMARY'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.paperHigh,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.hair),
            ),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: AppColors.hair),
                ),
                _SummaryRow(
                    label: 'Profit',
                    amount: order.profit,
                    color:
                        order.profit >= 0 ? AppColors.success : AppColors.alert,
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

  Widget? _buildBottomActions(BuildContext context, OrderDetailLoaded state) {
    final order = state.order;

    if (order.status == OrderStatus.shipped ||
        order.status == OrderStatus.cancelled) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.paperHigh,
        border: Border(top: BorderSide(color: AppColors.hair)),
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
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Pack this order'),
                ),
              ),
            ],
            if (order.status == OrderStatus.packed)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<OrderDetailBloc>()
                        .add(ShipOrderDetail(order.id!));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coin,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark shipped'),
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

    return Row(
      children: List.generate(steps.length, (index) {
        final isDone = index <= currentIndex;
        final isCurrent = index == currentIndex;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.success : AppColors.hair,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < steps.length - 1) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: AppTextStyles.monoSection);
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.paperHigh,
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
                Text('${item.quantity} × ${item.unitPrice.currency}',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          CurrencyText(
            amount: item.subtotal,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.paperHigh,
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
                Text(
                  'Planned: ${material.plannedQuantity} · Actual: ${material.actualQuantity}',
                  style: AppTextStyles.bodySmall,
                ),
                if (material.wasteQuantity > 0)
                  Text(
                    'Waste: ${material.wasteQuantity}${material.wasteReason != null ? ' (${material.wasteReason})' : ''}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.alert),
                  ),
              ],
            ),
          ),
          CurrencyText(
            amount: material.totalCost,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.bodyLarge.copyWith(color: AppColors.ink)
                : AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
          CurrencyText(
            amount: amount,
            style: (isBold ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium)
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
