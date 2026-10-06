import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/note_codec.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../../../core/widgets/product_photo.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../order_fields/domain/entities/order_field.dart';
import '../../../order_fields/domain/entities/order_field_entry.dart';
import '../../../order_fields/domain/order_field_codec.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_money.dart';
import '../../../settings/presentation/bloc/tax_settings_cubit.dart';
import '../../../discounts/domain/entities/discount_preset.dart';
import '../../domain/entities/order_discount.dart';
import '../bloc/order_detail_bloc.dart';
import '../bloc/order_detail_event.dart';
import '../bloc/order_detail_state.dart';
import '../../../../core/widgets/note/note_view.dart';
import '../widgets/order_actions.dart';
import '../widgets/order_status_ui.dart';
import '../widgets/pack_confirm_sheet.dart';
import 'adjust_materials_page.dart';
import 'note_editor_page.dart';

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
                appBar: AppBar(
                    leading:
                        BackButton(onPressed: () => context.pop(_changed))),
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
            Text(order.customerName,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'edit') _edit(order);
              if (value == 'cancel') _confirmCancel(order);
              if (value == 'restore') _confirmRestore(order);
              if (value == 'delete') _confirmDelete(order);
              if (value == 'paid') _setPaid(order, true);
              if (value == 'unpaid') _setPaid(order, false);
            },
            itemBuilder: (context) => [
              if (order.status != OrderStatus.cancelled)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 20),
                      const SizedBox(width: 10),
                      Text(order.status == OrderStatus.shipped
                          ? 'Edit note'
                          : 'Edit order'),
                    ],
                  ),
                ),
              if (order.status != OrderStatus.cancelled)
                PopupMenuItem(
                  value: order.isPaid ? 'unpaid' : 'paid',
                  child: Row(
                    children: [
                      Icon(
                          order.isPaid
                              ? Icons.money_off_rounded
                              : Icons.payments_outlined,
                          size: 20),
                      const SizedBox(width: 10),
                      Text(order.isPaid ? 'Mark unpaid' : 'Mark paid'),
                    ],
                  ),
                ),
              if (OrderActions.canCancel(order))
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.block_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('Cancel order'),
                    ],
                  ),
                ),
              if (order.status == OrderStatus.cancelled)
                const PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(Icons.restore_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('Restore order'),
                    ],
                  ),
                ),
              if (order.status != OrderStatus.shipped)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 20, color: c.alert),
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
              _CustomerCard(
                order: order,
                channelName: state.channel?.name,
                fields: state.fieldValues,
                onEditNote: () => _editNote(order),
                onNoteChanged: (note) => _saveNote(order, note),
              ),
              const SizedBox(height: 12),
              if (state.items.isNotEmpty) ...[
                AppCard.flush(
                  child: CardList(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        child: Text(
                          'ITEMS',
                          style:
                              AppTextStyles.monoLabel.copyWith(color: c.muted),
                        ),
                      ),
                      for (final item in state.items)
                        CardRow(
                          leading: ProductPhoto(
                            bytes: item.productPhoto,
                            name: item.productName,
                            size: 56,
                            onTap: () => showPhotoViewer(
                              context,
                              bytes: item.productPhoto!,
                              title: item.productName,
                            ),
                          ),
                          title: Text(item.productName),
                          subtitle: Text(
                            '${QuantityFormatter.withUnit(item.quantity, item.unit)}'
                            ' × ${CurrencyFormatter.formatShort(item.unitPrice)}',
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
                      _TermsLines(
                        order: order,
                        discounts: state.discounts,
                        taxLabel: getIt<TaxSettingsCubit>().state.label,
                      ),
                      _OrderTotalRow(total: order.liveTotal),
                      if (order.status != OrderStatus.cancelled)
                        _PaymentRow(
                          order: order,
                          onToggle: () => _setPaid(order, !order.isPaid),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _buildMoneyCard(state),
            ],
          ),
          if (state.isBusy)
            const Positioned(
                left: 0, right: 0, top: 0, child: LinearProgressIndicator()),
        ],
      ),
      bottomNavigationBar: _buildActions(state),
    );
  }

  /// Where the sale went, with profit as the bottom line. The total to
  /// charge lives on the items card so it can't be mistaken for profit.
  Widget _buildMoneyCard(OrderDetailLoaded state) {
    final c = context.colors;
    final order = state.order;
    final parts = OrderMoney.fromOrder(order).parts;
    final lineCount = state.materials.length + state.products.length;
    final hasWaste = state.materials.any((m) => m.wasteQuantity > 0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MoneyBreakdown(
            parts: parts,
            materialsLabel: lineCount == 0
                ? 'Materials'
                : 'Materials · $lineCount ${lineCount == 1 ? 'line' : 'lines'}'
                    '${hasWaste ? ' · waste' : ''}',
            feesLabel: state.channel == null
                ? 'Channel fees'
                : '${state.channel!.name} fees',
            taxLabel: getIt<TaxSettingsCubit>().state.label,
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
                                ? '${QuantityFormatter.withUnit(m.actualQuantity, m.materialUnit)}'
                                    ' × ${CurrencyFormatter.format(m.unitCost)}'
                                : 'Planned ${QuantityFormatter.withUnit(m.plannedQuantity, m.materialUnit)}'
                                    ' · used ${QuantityFormatter.withUnit(m.actualQuantity, m.materialUnit)}',
                            waste: m.wasteQuantity > 0
                                ? '+${QuantityFormatter.withUnit(m.wasteQuantity, m.materialUnit)} waste'
                                    '${m.wasteReason != null ? ' (${m.wasteReason!.toLowerCase()})' : ''}'
                                : null,
                            amount: m.totalCost,
                          ),
                        for (final p in state.products)
                          _LineDetail(
                            name: p.productName,
                            detail:
                                '${QuantityFormatter.withUnit(p.quantity, p.productUnit)}'
                                ' × ${CurrencyFormatter.format(p.unitCost)} · from stock',
                            amount: p.totalCost,
                          ),
                      ],
                    ),
                  ),
          ),
          ProfitRow(parts: parts),
        ],
      ),
    );
  }

  void _setPaid(Order order, bool paid) {
    _changed = true;
    _bloc.add(SetOrderPaidDetail(order.id!, paid: paid));
  }

  Future<void> _editNote(Order order) async {
    final saved = await NoteEditorPage.open(context, note: order.note);
    if (saved != null && mounted) _saveNote(order, saved.note);
  }

  void _saveNote(Order order, String? note) {
    _changed = true;
    _bloc.add(SaveOrderNote(orderId: order.id!, note: note));
  }

  Future<void> _edit(Order order) async {
    final changed =
        await context.push<bool>(RouteNames.editOrderPath(order.id!));
    if (changed == true && mounted) {
      _changed = true;
      _bloc.add(LoadOrderDetail(widget.orderId));
    }
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
              onPressed:
                  busy ? null : () => _bloc.add(ShipOrderDetail(order.id!)),
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
          child: AdjustMaterialsPage(
              orderId: state.order.id!, materials: state.materials),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(Order order) async {
    final confirmed = await OrderActions.confirmCancel(context, order);
    if (confirmed && mounted) {
      _changed = true;
      _bloc.add(CancelOrderDetail(order.id!));
    }
  }

  Future<void> _confirmRestore(Order order) async {
    final confirmed = await OrderActions.confirmRestore(context, order);
    if (confirmed && mounted) {
      _changed = true;
      _bloc.add(RestoreOrderDetail(order.id!));
    }
  }

  Future<void> _confirmDelete(Order order) async {
    final confirmed = await OrderActions.confirmDelete(context, order);
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
                              : Container(
                                  height: 2,
                                  color: i <= reached ? c.go : c.hair),
                        ),
                        _TrackDot(
                            index: i, reached: reached, alert: steps[i].$3),
                        Expanded(
                          child: i == steps.length - 1
                              ? const SizedBox()
                              : Container(
                                  height: 2,
                                  color: i < reached ? c.go : c.hair),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[i].$1,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: i <= reached + 1 ? c.ink : c.muted,
                      fontWeight:
                          i <= reached + 1 ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (steps[i].$2.isNotEmpty)
                    Text(
                      steps[i].$2,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: steps[i].$3 ? c.alert : c.muted,
                        fontWeight:
                            steps[i].$3 ? FontWeight.w600 : FontWeight.w400,
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

  const _TrackDot(
      {required this.index, required this.reached, required this.alert});

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
  final VoidCallback onEditNote;
  final List<OrderFieldEntry> fields;
  final ValueChanged<String?> onNoteChanged;

  const _CustomerCard({
    required this.order,
    this.channelName,
    this.fields = const [],
    required this.onEditNote,
    required this.onNoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final muted =
        AppTextStyles.bodySmall.copyWith(color: c.muted, fontSize: 13);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                  child: SectionLabel('Customer', padding: EdgeInsets.zero)),
              if (channelName != null)
                AppTag(channelName!, type: AppTagType.outline),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.customerName,
              style: AppTextStyles.bodyLarge.copyWith(color: c.ink)),
          for (final entry in fields) ...[
            const SizedBox(height: 8),
            Text(
              entry.field.name,
              style: AppTextStyles.bodySmall
                  .copyWith(color: c.muted, fontSize: 11.5),
            ),
            if (entry.field.type == OrderFieldType.text)
              _CopyableValue(
                  text: entry.value, label: entry.field.name, style: muted)
            else
              Text(OrderFieldCodec.display(entry.field, entry.value),
                  style: muted),
          ],
          if (!NoteCodec.isBlank(order.note)) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                color: c.warnSoft,
                borderRadius: AppRadii.controlAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(Icons.sticky_note_2_outlined,
                        size: 16, color: c.warn),
                  ),
                  const SizedBox(width: 8),
                  // To-dos tick right here, so a packing checklist works
                  // without opening the editor.
                  Expanded(
                      child:
                          NoteView(raw: order.note!, onChanged: onNoteChanged)),
                  IconButton(
                    tooltip: 'Edit note',
                    onPressed: onEditNote,
                    icon: Icon(Icons.edit_outlined, size: 16, color: c.warn),
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints.tightFor(width: 32, height: 28),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
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
                  style: AppTextStyles.bodySmall.copyWith(
                      color: c.ink, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(detail,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: c.muted, fontSize: 12)),
                if (waste != null)
                  Text(
                    waste!,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: c.alert,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
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

/// A value that copies itself when tapped, for pasting into a shipping label
/// or a message.
class _CopyableValue extends StatelessWidget {
  final String text;
  final String label;
  final TextStyle style;

  const _CopyableValue(
      {required this.text, required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        context.showSnackBar('$label copied');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(text, style: style)),
            const SizedBox(width: 8),
            Icon(Icons.copy_rounded, size: 15, color: c.muted),
          ],
        ),
      ),
    );
  }
}

/// The last line of the items card: what the customer pays.
/// Discount lines and tax between the items and the order total.
class _TermsLines extends StatelessWidget {
  final Order order;
  final List<OrderDiscount> discounts;
  final String taxLabel;

  const _TermsLines({
    required this.order,
    required this.discounts,
    required this.taxLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = OrderMoney.fromOrder(order);
    final rate = order.taxRate;
    final rateText = rate == null
        ? ''
        : rate == rate.roundToDouble()
            ? rate.toStringAsFixed(0)
            : '$rate';
    Widget line(String label, String amount, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
              ),
              Text(
                amount,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color ?? c.ink,
                  fontWeight: FontWeight.w600,
                  fontFeatures: AppTextStyles.tabular.fontFeatures,
                ),
              ),
            ],
          ),
        );

    final lines = <Widget>[
      if (discounts.isNotEmpty)
        for (final d in discounts)
          line('${d.label} · ${discountValueLabel(d.kind, d.value)}',
              '−${CurrencyFormatter.format(d.amount)}',
              color: c.go)
      else if (order.hasDiscount)
        line('Discounts', '−${CurrencyFormatter.format(order.discountTotal)}',
            color: c.go),
      if (order.hasTax && !order.taxInclusive)
        line('$taxLabel $rateText%', '+${CurrencyFormatter.format(money.tax)}'),
      if (order.hasTax && order.taxInclusive)
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            'Includes ${CurrencyFormatter.format(money.tax)} $taxLabel ($rateText%)',
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
        ),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    // Same breathing room above and below, so the divider under the last
    // line never touches it, whichever lines are shown.
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line('Items', CurrencyFormatter.format(order.totalSales)),
          ...lines,
        ],
      ),
    );
  }
}

/// Paid or waiting for payment, with a one-tap switch.
class _PaymentRow extends StatelessWidget {
  final Order order;
  final VoidCallback onToggle;

  const _PaymentRow({required this.order, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final paidAt = order.paidAt;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 6, 8),
      child: Row(
        children: [
          Icon(
            order.isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 18,
            color: order.isPaid ? c.go : c.warn,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              order.isPaid
                  ? 'Paid${paidAt == null ? '' : ' ${DateFormat('MMM d').format(paidAt)}'}'
                  : 'Waiting for payment',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: order.isPaid ? c.muted : c.warn),
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: Text(order.isPaid ? 'Mark unpaid' : 'Mark paid'),
          ),
        ],
      ),
    );
  }
}

class _OrderTotalRow extends StatelessWidget {
  final double total;

  const _OrderTotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              'ORDER TOTAL',
              style: AppTextStyles.monoLabel.copyWith(color: c.muted),
            ),
          ),
          Text(
            CurrencyFormatter.format(total),
            style: AppTextStyles.displayMedium
                .copyWith(fontSize: 26, color: c.ink),
          ),
        ],
      ),
    );
  }
}
