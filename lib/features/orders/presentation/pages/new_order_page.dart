import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/inline_banner.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../../products/domain/entities/channel.dart';
import '../../../products/domain/usecases/get_channels.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/usecases/preview_order.dart';
import '../bloc/new_order_bloc.dart';
import '../bloc/new_order_event.dart';
import '../bloc/new_order_state.dart';
import '../widgets/product_picker_sheet.dart';

/// New order: Customer → Items → Review.
class NewOrderPage extends StatelessWidget {
  const NewOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NewOrderBloc>()..add(ResetOrder()),
      child: const _NewOrderView(),
    );
  }
}

class _NewOrderView extends StatefulWidget {
  const _NewOrderView();

  @override
  State<_NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<_NewOrderView> {
  static const _stepNames = ['Customer', 'Items', 'Review'];

  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _orderDate = DateUtils.dateOnly(DateTime.now());
  DateTime _shipByDate = DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 2));
  int? _channelId;
  List<Channel> _channels = [];
  bool _channelsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    final result = await getIt<GetChannels>()(activeOnly: true);
    if (!mounted) return;
    setState(() {
      _channelsLoaded = true;
      if (result case Success(:final value)) {
        _channels = value;
        if (_channelId == null && value.isNotEmpty) _channelId = value.first.id;
      }
    });
    if (result case Error(:final failure)) {
      context.showSnackBar(failure.message, isError: true);
    }
  }

  Channel? get _channel => _channels.where((c) => c.id == _channelId).firstOrNull;

  void _goTo(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    if (step == 2) context.read<NewOrderBloc>().add(RequestPreview());
  }

  void _submitDetails() {
    if (!_formKey.currentState!.validate()) return;
    if (_channelId == null) {
      context.showSnackBar('Pick a sales channel', isError: true);
      return;
    }
    context.read<NewOrderBloc>().add(SetCustomerDetails(
          customerName: _nameController.text.trim(),
          customerAddress: _addressController.text.trim(),
          channelId: _channelId!,
          orderDate: _orderDate,
          shipByDate: _shipByDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        ));
    _goTo(1);
  }

  Future<bool> _confirmDiscard(List<OrderItemInput> items) async {
    final dirty = _nameController.text.trim().isNotEmpty || items.isNotEmpty;
    if (!dirty) return true;
    return ConfirmDialog.show(
      context,
      title: 'Discard this order?',
      message: "What you've entered so far will be lost.",
      confirmText: 'Discard',
      cancelText: 'Keep editing',
      isDestructive: true,
    );
  }

  Future<void> _handleBack(List<OrderItemInput> items) async {
    if (_step > 0) {
      _goTo(_step - 1);
      return;
    }
    if (await _confirmDiscard(items) && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewOrderBloc, NewOrderState>(
      listener: (context, state) {
        if (state is NewOrderSaved) {
          context.showSnackBar('Order #${state.orderId} saved');
          context.pop(true);
        }
        if (state is NewOrderError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      buildWhen: (_, s) => s is! NewOrderError,
      builder: (context, state) {
        final details = state is NewOrderDetailsFilled ? state : null;
        final items = details?.items ?? const <OrderItemInput>[];

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleBack(items);
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: _step == 0 ? 'Close' : 'Back',
                icon: Icon(_step == 0 ? Icons.close_rounded : Icons.arrow_back_rounded),
                onPressed: () => _handleBack(items),
              ),
              title: const Text('New order'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: _StepHeader(names: _stepNames, current: _step),
              ),
            ),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCustomerStep(),
                _buildItemsStep(items),
                _buildReviewStep(details),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(details, items),
          ),
        );
      },
    );
  }

  // ── Step 1 ───────────────────────────────────────────────────────────

  Widget _buildCustomerStep() {
    final c = context.colors;
    return Form(
      key: _formKey,
      child: ListView(
        padding: AppSpacing.page.copyWith(top: 12),
        children: [
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Customer name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter the customer name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Address (optional)'),
          ),
          const SizedBox(height: 8),
          const SectionLabel('Channel'),
          const SizedBox(height: 8),
          if (!_channelsLoaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            )
          else if (_channels.isEmpty)
            InlineBanner(
              icon: Icons.storefront_outlined,
              tone: BannerTone.warn,
              title: 'No sales channels yet.',
              message: 'Add one to work out fees.',
              actionLabel: 'Add',
              onTap: () async {
                await context.push(RouteNames.channels);
                if (mounted) _loadChannels();
              },
            )
          else
            ChoiceChipRow<int?>.single(
              wrap: true,
              selected: _channelId,
              onSelected: (id) => setState(() => _channelId = id),
              options: [for (final ch in _channels) ChipOption(ch.id, ch.name)],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DateField(
                  label: 'Order date',
                  value: _orderDate,
                  onChanged: (d) => setState(() {
                    _orderDate = d;
                    if (_shipByDate.isBefore(d)) _shipByDate = d;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DateField(
                  label: 'Ship by',
                  value: _shipByDate,
                  firstDate: _orderDate,
                  onChanged: (d) => setState(() => _shipByDate = d),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'Gift wrap, colour requests…',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: c.muted),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2 ───────────────────────────────────────────────────────────

  void _openPicker(List<OrderItemInput> items) {
    final bloc = context.read<NewOrderBloc>();
    ProductPickerSheet.show(
      context,
      addedProductIds: [for (final i in items) i.productId],
      onSelected: (item) => bloc.add(AddItem(
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      )),
    );
  }

  Widget _buildItemsStep(List<OrderItemInput> items) {
    final c = context.colors;
    if (items.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.add_shopping_cart_rounded,
          title: 'No items yet',
          message: 'Add the products this customer ordered.',
          actionLabel: 'Add product',
          onAction: () => _openPicker(items),
        ),
      );
    }
    return ListView(
      padding: AppSpacing.page.copyWith(top: 12),
      children: [
        AppCard.flush(
          child: CardList(
            children: [
              for (final item in items)
                CardRow(
                  title: Text(item.productName),
                  subtitle: Text(
                    '${CurrencyFormatter.formatShort(item.unitPrice)} each · '
                    '${CurrencyFormatter.formatShort(item.subtotal)}',
                  ),
                  trailing: StepperInput(
                    value: item.quantity,
                    min: 0,
                    onChanged: (v) {
                      final bloc = context.read<NewOrderBloc>();
                      if (v.toInt() == 0) {
                        bloc.add(RemoveItem(item.productId));
                      } else {
                        bloc.add(UpdateItemQuantity(
                          productId: item.productId,
                          quantity: v.toInt(),
                        ));
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _openPicker(items),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Add product'),
        ),
        const SizedBox(height: 10),
        Text(
          'Set a quantity to 0 to remove it.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: c.muted),
        ),
      ],
    );
  }

  // ── Step 3 ───────────────────────────────────────────────────────────

  Widget _buildReviewStep(NewOrderDetailsFilled? d) {
    final c = context.colors;
    if (d == null) return const SizedBox.shrink();
    final pieces = d.items.fold<int>(0, (s, i) => s + i.quantity);
    final preview = d.preview;

    return ListView(
      padding: AppSpacing.page.copyWith(top: 12),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.customerName,
                      style: AppTextStyles.bodyLarge.copyWith(color: c.ink, fontSize: 16),
                    ),
                  ),
                  if (_channel != null) AppTag(_channel!.name, type: AppTagType.outline),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ships by ${DateFormat('EEE, MMM d').format(d.shipByDate)} · '
                '$pieces ${pieces == 1 ? 'item' : 'items'}',
                style: AppTextStyles.bodySmall.copyWith(color: c.muted),
              ),
              if (d.customerAddress.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  d.customerAddress,
                  style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (d.isPreviewing || (preview == null && d.previewError == null))
          const AppCard(
            child: SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (d.previewError != null)
          ErrorState(
            message: d.previewError!,
            onRetry: () => context.read<NewOrderBloc>().add(RequestPreview()),
          )
        else ...[
          _ProfitPreviewCard(preview: preview!, channelName: _channel?.name),
          const SizedBox(height: 12),
          if (preview.reservations.any((r) => r.isShort)) ...[
            const InlineBanner(
              icon: Icons.warning_amber_rounded,
              title: 'Not enough stock for some pieces.',
              message: 'You can still save; the buy list will show what to get.',
            ),
            const SizedBox(height: 12),
          ],
          if (preview.reservations.isNotEmpty) _ReservationsCard(lines: preview.reservations),
        ],
      ],
    );
  }

  // ── Bottom bar ───────────────────────────────────────────────────────

  Widget _buildBottomBar(NewOrderDetailsFilled? d, List<OrderItemInput> items) {
    final total = CurrencyFormatter.formatShort(d?.totalSales ?? 0);
    switch (_step) {
      case 0:
        return BottomActionBar(children: [
          Expanded(
            child: FilledButton(
              onPressed: _submitDetails,
              child: const Text('Next: add items'),
            ),
          ),
        ]);
      case 1:
        return BottomActionBar(children: [
          BarTotal(label: 'Total', value: total),
          FilledButton(
            onPressed: items.isEmpty ? null : () => _goTo(2),
            child: const Text('Review'),
          ),
        ]);
      default:
        final saving = d?.isSaving ?? false;
        return BottomActionBar(children: [
          BarTotal(label: 'Total', value: total),
          FilledButton.icon(
            onPressed: saving || d?.preview == null
                ? null
                : () => context.read<NewOrderBloc>().add(SaveOrder()),
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded, size: 20),
            label: const Text('Save order'),
          ),
        ]);
    }
  }
}

/// Labelled progress bars under the app bar.
class _StepHeader extends StatelessWidget {
  final List<String> names;
  final int current;

  const _StepHeader({required this.names, required this.current});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          for (var i = 0; i < names.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= current ? c.go : c.hair,
                      borderRadius: AppRadii.pillAll,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${i + 1}  ${names[i]}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: i == current ? c.ink : c.muted,
                      fontWeight: i == current ? FontWeight.w600 : FontWeight.w500,
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

class _ProfitPreviewCard extends StatelessWidget {
  final OrderPreview preview;
  final String? channelName;

  const _ProfitPreviewCard({required this.preview, this.channelName});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final parts = MoneyParts(
      sales: preview.sales,
      materials: preview.materialCost,
      fees: preview.channelFees,
      shipping: preview.shippingCost,
    );
    final positive = parts.profit >= 0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PROFIT PREVIEW',
            style: AppTextStyles.monoLabel.copyWith(color: c.muted),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.formatShort(parts.profit),
                style: AppTextStyles.displayMedium.copyWith(color: positive ? c.go : c.alert),
              ),
              const SizedBox(width: 8),
              Text(
                '${(parts.margin * 100).round()}% margin',
                style: AppTextStyles.bodySmall.copyWith(color: c.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MoneyBreakdown(
            parts: parts,
            feesLabel: channelName == null ? 'Channel fees' : '$channelName fees',
          ),
        ],
      ),
    );
  }
}

class _ReservationsCard extends StatelessWidget {
  final List<ReservationLine> lines;

  const _ReservationsCard({required this.lines});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'RESERVES FROM STOCK',
            style: AppTextStyles.monoLabel.copyWith(color: c.muted),
          ),
          const SizedBox(height: 6),
          for (final r in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      r.name,
                      style: AppTextStyles.bodyMedium.copyWith(color: c.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    r.isShort
                        ? '${r.quantity} · only ${r.available < 0 ? 0 : r.available} free'
                        : r.usesLast
                            ? '${r.quantity} · last ${r.quantity == 1 ? 'one' : 'ones'}'
                            : '${r.quantity} pcs',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: r.isShort || r.usesLast ? c.alert : c.ink,
                      fontWeight: FontWeight.w600,
                      fontFeatures: AppTextStyles.tabular.fontFeatures,
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
